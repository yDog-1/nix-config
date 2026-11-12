---
name: comma
description: Run missing commands from nixpkgs with comma (,), without installing them permanently. Use when a command is not found or a task needs a CLI that is not on PATH.
---

# Run missing commands with comma

When a required command is missing, use `, <command> <args...>` before installing packages or changing Nix configuration.

1. Check availability with `command -v <command>`. Use the existing command if available.
2. If missing, run the executable name through comma. Pass arguments as separate shell arguments, as usual.

   ```sh
   , jq '.name' package.json
   , pandoc --from markdown --to html README.md
   ```

3. If comma offers multiple packages, choose the package that provides the intended tool. Use `, -p <command>` to list candidates. Do not select an arbitrary first result.
4. If the runner cannot use the interactive picker, use `nix shell nixpkgs#<package> -c <command> <args...>` with a verified package attribute.

Comma looks up executable names in the nix-index database and runs them from nixpkgs. The package name can differ from the executable name. Downloads or builds may require network access and time.

Prefix each missing command separately. In `, tool-a | tool-b`, comma provides only `tool-a`. Use `, tool-a | , tool-b` if both commands are missing.

Do not use `, -i` or change system or Home Manager packages for a one-off task. Comma does not bypass permission restrictions. If comma itself is missing, the lookup fails, or a download or build fails, report the actual error and use a verified `nix shell` command when possible. Do not treat a tool's own failure as a missing-command error.
