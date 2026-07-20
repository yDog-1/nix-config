const vt = "@vde-tmux@/bin/vt"
const pendingPermissions = new Map<string, Set<string>>()
const busySessions = new Set<string>()
const pendingPrompts = new Map<string, string>()

async function emit(sessionID: string, args: string[]) {
  const process = Bun.spawn([vt, "hook", "emit", "--agent", "opencode", "--session-id", sessionID, ...args], {
    stderr: "ignore",
    stdout: "ignore",
  })

  await process.exited
}

function prompt(parts: Array<{ type: string; text?: string; synthetic?: boolean }>) {
  return parts
    .filter((part) => part.type === "text" && !part.synthetic && part.text)
    .map((part) => part.text)
    .join("\n")
    .slice(0, 4000)
}

function addPermission(sessionID: string, requestID: string) {
  const requests = pendingPermissions.get(sessionID) ?? new Set()
  requests.add(requestID)
  pendingPermissions.set(sessionID, requests)
}

function removePermission(sessionID: string, requestID: string) {
  const requests = pendingPermissions.get(sessionID)
  if (!requests) return

  requests.delete(requestID)
  if (requests.size === 0) pendingPermissions.delete(sessionID)
}

function hasPendingPermission(sessionID: string) {
  return (pendingPermissions.get(sessionID)?.size ?? 0) > 0
}

function clearSession(sessionID: string) {
  pendingPermissions.delete(sessionID)
  busySessions.delete(sessionID)
  pendingPrompts.delete(sessionID)
}

export default async function OpenCodeVdeTmuxPlugin() {
  return {
    "chat.message": async (input, output) => {
      const text = prompt(output.parts)
      if (text) pendingPrompts.set(input.sessionID, text)
    },
    event: async ({ event }) => {
      switch (event.type) {
        case "permission.asked":
          addPermission(event.properties.sessionID, event.properties.id)
          // A later busy event, after the reply, is the authoritative resume signal.
          busySessions.delete(event.properties.sessionID)
          await emit(event.properties.sessionID, [
            "--status",
            "waiting",
            "--wait-reason",
            "permission_prompt",
          ])
          break
        case "permission.replied":
          removePermission(event.properties.sessionID, event.properties.requestID)
          break
        case "session.status":
          if (
            event.properties.status.type === "busy" &&
            !busySessions.has(event.properties.sessionID) &&
            !hasPendingPermission(event.properties.sessionID)
          ) {
            busySessions.add(event.properties.sessionID)
            const args = [
              "--status",
              "running",
              "--started-at",
              `${Math.floor(Date.now() / 1000)}`,
            ]
            const text = pendingPrompts.get(event.properties.sessionID)

            if (text) args.push("--prompt", text, "--prompt-source", "user")
            await emit(event.properties.sessionID, args)
          }
          break
        case "session.idle":
          clearSession(event.properties.sessionID)
          await emit(event.properties.sessionID, [
            "--status",
            "idle",
            "--completed-at",
            `${Math.floor(Date.now() / 1000)}`,
          ])
          break
        case "session.error":
          if (event.properties.sessionID) {
            clearSession(event.properties.sessionID)
            await emit(event.properties.sessionID, ["--status", "error"])
          }
          break
        case "todo.updated": {
          const done = event.properties.todos.filter(
            (todo) => todo.status === "completed" || todo.status === "cancelled",
          ).length
          await emit(event.properties.sessionID, ["--tasks", `${done}/${event.properties.todos.length}`])
          break
        }
      }
    },
  }
}
