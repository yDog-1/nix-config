# Neovim formatter and linter checks

Run these checks from the repository root. They use a clean Neovim process,
temporary project fixtures, and the plugin revisions in
`layat/ydog-1/.config/nvim/lazy-lock.json`. They do not load the live user config.

Set `CONFORM_DIR` and `LINT_DIR` to checkouts of `stevearc/conform.nvim` and
`mfussenegger/nvim-lint` at their locked revisions. Existing lazy.nvim checkouts
can be used if their HEADs match the lock file:

```sh
lock=layat/ydog-1/.config/nvim/lazy-lock.json
test "$(git -C "$CONFORM_DIR" rev-parse HEAD)" = "$(jq -r '.["conform.nvim"].commit' "$lock")"
test "$(git -C "$LINT_DIR" rev-parse HEAD)" = "$(jq -r '.["nvim-lint"].commit' "$lock")"
```

Build the test tools from the flake without activating Home Manager:

```sh
tools=.#homeConfigurations.ydog-1.pkgs
nvim_bin="$(nix build --no-link --print-out-paths "$tools.neovim")/bin/nvim"
ruff_bin="$(nix build --no-link --print-out-paths "$tools.ruff")/bin/ruff"
gdscript_bin="$(nix build --no-link --print-out-paths "$tools.gdscript-formatter")/bin/gdscript-formatter"
prettier_bin="$(nix build --no-link --print-out-paths "$tools.prettier")/bin/prettier"
biome_bin="$(nix build --no-link --print-out-paths "$tools.biome")/bin/biome"
eslint_bin="$(nix build --no-link --print-out-paths "$tools.eslint")/bin/eslint"

"$nvim_bin" --headless -u NONE -i NONE -l tests/nvim/lint.lua "$LINT_DIR"
"$nvim_bin" --headless -u NONE -i NONE -l tests/nvim/format.lua "$CONFORM_DIR"
"$nvim_bin" --headless -u NONE -i NONE -l tests/nvim/languages.lua \
  "$CONFORM_DIR" "$LINT_DIR" "$ruff_bin" "$gdscript_bin"
"$nvim_bin" --headless -u NONE -i NONE -l tests/nvim/web.lua \
  "$CONFORM_DIR" "$LINT_DIR" "$prettier_bin" "$biome_bin" "$eslint_bin"
```

The lint regression check intercepts process spawning while retaining the real
nvim-lint selection, filtering, and wrapping code. It covers multiple buffers,
workspace executables, ESLint config variants, removed configs, compound
filetypes, and saved-file versus stdin events.

The format regression check uses deterministic fixture commands to check
formatter selection, config requirements, and that `BufWritePost` sees the
formatted content after one write. The language and web integration checks
invoke the real tools to check diagnostics, unsaved changes, project settings,
and GDScript `.editorconfig` discovery.

Temporary fixtures respect `TMPDIR` and are removed after each check.
