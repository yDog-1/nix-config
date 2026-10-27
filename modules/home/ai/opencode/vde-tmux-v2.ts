const vt = "@vde-tmux@/bin/vt";

export default {
  id: "vde-tmux",
  async setup(ctx) {
    const pendingPermissions = new Map<string, Set<string>>();
    const activeSessions = new Set<string>();
    const busySessions = new Set<string>();
    const pendingPrompts = new Map<string, string>();
    const inboxPrompts = new Map<string, string>();
    const todoCalls = new Set<string>();
    const controller = new AbortController();

    async function emit(sessionID: string, args: string[]) {
      const process = Bun.spawn(
        [
          vt,
          "hook",
          "emit",
          "--agent",
          "opencode",
          "--session-id",
          sessionID,
          ...args,
        ],
        { stderr: "ignore", stdout: "ignore" },
      );
      await process.exited;
    }

    async function running(sessionID: string) {
      if (busySessions.has(sessionID) || pendingPermissions.has(sessionID))
        return;
      busySessions.add(sessionID);
      const args = [
        "--status",
        "running",
        "--started-at",
        `${Math.floor(Date.now() / 1000)}`,
      ];
      const text = pendingPrompts.get(sessionID);
      if (text) args.push("--prompt", text, "--prompt-source", "user");
      await emit(sessionID, args);
    }

    async function finish(sessionID: string, status: string) {
      pendingPermissions.delete(sessionID);
      activeSessions.delete(sessionID);
      busySessions.delete(sessionID);
      pendingPrompts.delete(sessionID);
      for (const key of todoCalls)
        if (key.startsWith(`${sessionID}:`)) todoCalls.delete(key);
      const args = ["--status", status];
      if (status === "idle")
        args.push("--completed-at", `${Math.floor(Date.now() / 1000)}`);
      await emit(sessionID, args);
    }

    void (async () => {
      try {
        for await (const event of ctx.event.subscribe({
          signal: controller.signal,
        })) {
          try {
            const data = event.data;
            switch (event.type) {
              case "session.inbox.enqueued":
                if (data.item.type === "user" && data.item.payload.text) {
                  inboxPrompts.set(
                    `${data.sessionID}:${data.inboxID}`,
                    data.item.payload.text.slice(0, 4000),
                  );
                  if (!activeSessions.has(data.sessionID))
                    pendingPrompts.set(
                      data.sessionID,
                      data.item.payload.text.slice(0, 4000),
                    );
                }
                break;
              case "session.inbox.delivered": {
                const key = `${data.sessionID}:${data.inboxID}`;
                const text = inboxPrompts.get(key);
                inboxPrompts.delete(key);
                if (text) pendingPrompts.set(data.sessionID, text);
                break;
              }
              case "session.inbox.cancelled":
                inboxPrompts.delete(`${data.sessionID}:${data.inboxID}`);
                break;
              case "session.deleted":
                pendingPermissions.delete(data.sessionID);
                activeSessions.delete(data.sessionID);
                busySessions.delete(data.sessionID);
                pendingPrompts.delete(data.sessionID);
                for (const key of inboxPrompts.keys())
                  if (key.startsWith(`${data.sessionID}:`))
                    inboxPrompts.delete(key);
                for (const key of todoCalls)
                  if (key.startsWith(`${data.sessionID}:`))
                    todoCalls.delete(key);
                break;
              case "permission.asked": {
                const requests =
                  pendingPermissions.get(data.sessionID) ?? new Set<string>();
                requests.add(data.id);
                pendingPermissions.set(data.sessionID, requests);
                busySessions.delete(data.sessionID);
                await emit(data.sessionID, [
                  "--status",
                  "waiting",
                  "--wait-reason",
                  "permission_prompt",
                ]);
                break;
              }
              case "permission.replied": {
                const requests = pendingPermissions.get(data.sessionID);
                if (!requests?.delete(data.requestID)) break;
                if (requests.size === 0) {
                  pendingPermissions.delete(data.sessionID);
                  await running(data.sessionID);
                }
                break;
              }
              case "session.execution.started":
                activeSessions.add(data.sessionID);
                await running(data.sessionID);
                break;
              case "session.execution.succeeded":
              case "session.execution.interrupted":
                await finish(data.sessionID, "idle");
                break;
              case "session.execution.failed":
                await finish(data.sessionID, "error");
                break;
              case "session.tool.input.started":
                if (data.name === "todowrite")
                  todoCalls.add(
                    `${data.sessionID}:${data.assistantMessageID}:${data.id}`,
                  );
                break;
              case "session.tool.failed":
                todoCalls.delete(
                  `${data.sessionID}:${data.assistantMessageID}:${data.id}`,
                );
                break;
              case "session.tool.success": {
                const key = `${data.sessionID}:${data.assistantMessageID}:${data.id}`;
                if (
                  !todoCalls.delete(key) ||
                  !Array.isArray(data.metadata?.todos)
                )
                  break;
                const todos = data.metadata.todos;
                const done = todos.filter(
                  (todo) =>
                    todo.status === "completed" || todo.status === "cancelled",
                ).length;
                await emit(data.sessionID, [
                  "--tasks",
                  `${done}/${todos.length}`,
                ]);
                break;
              }
            }
          } catch (error) {
            console.error("vde-tmux event handling failed", error);
          }
        }
      } catch (error) {
        if (!controller.signal.aborted)
          console.error("vde-tmux event subscription failed", error);
      }
    })();

    return () => controller.abort();
  },
};
