-- Run with nvim --headless -u NONE -i NONE -l tests/nvim/lint.lua /path/to/nvim-lint
local root = vim.fn.getcwd()
vim.opt.runtimepath:prepend(root .. "/layat/ydog-1/.config/nvim")
vim.opt.runtimepath:prepend(assert(arg[1], "Pass the pinned nvim-lint checkout"))

local tmp = "/tmp/opencode/neovim-lint-test-" .. vim.uv.os_getpid()
local function write(path, lines, executable)
	vim.fn.mkdir(vim.fs.dirname(path), "p")
	vim.fn.writefile(lines or {}, path)
	if executable then
		vim.fn.setfperm(path, "rwxr-xr-x")
	end
end
local function equal(expected, actual)
	assert(vim.deep_equal(expected, actual), "expected " .. vim.inspect(expected) .. ", got " .. vim.inspect(actual))
end

local function test()
	local workspace = tmp .. "/workspace"
	local app = workspace .. "/packages/app"
	write(workspace .. "/.git", {})
	write(workspace .. "/node_modules/.bin/eslint", { "#!/bin/sh", "exit 0" }, true)
	write(workspace .. "/node_modules/.bin/biome", { "#!/bin/sh", "exit 0" }, true)
	write(app .. "/biome.json", { "{}" })
	write(app .. "/eslint.config.cjs", { "module.exports = {}" })
	write(app .. "/src/a.ts", { "const a = 1" })
	write(app .. "/src/b.ts", { "const b = 2" })
	vim.cmd.cd(tmp)

	local lint = require("lint")
	local calls = {}
	-- Keep the real try_lint/filter/wrap_linter implementation; intercept spawning.
	lint.lint = function(linter, opts)
		calls[#calls + 1] = { name = linter.name, command = linter.cmd, cwd = opts.cwd, env = linter.env }
	end
	local spec = dofile(root .. "/layat/ydog-1/.config/nvim/lua/plugins/nvim-lint.lua")
	spec[1].config()
	local function open(path, ft)
		vim.cmd("noautocmd edit " .. vim.fn.fnameescape(path))
		vim.bo.filetype = ft
		return vim.api.nvim_get_current_buf()
	end
	local function run(bufnr, event)
		calls = {}
		vim.api.nvim_exec_autocmds(event, { group = "ydog.lint", buffer = bufnr })
		local result = {}
		for _, call in ipairs(calls) do
			result[call.name] = call
		end
		return result
	end

	local a = open(app .. "/src/a.ts", "typescript")
	local b = open(app .. "/src/b.ts", "typescript")
	for _, bufnr in ipairs({ a, b, a }) do
		local result = run(bufnr, "BufEnter")
		assert(result.biomejs and result.eslint and result.typos and result.gitleaks)
		equal(app, result.eslint.cwd)
		equal(app, result.biomejs.cwd)
		equal(workspace .. "/node_modules/.bin/eslint", result.eslint.command)
		equal(workspace .. "/node_modules/.bin/biome", result.biomejs.command)
		equal("true", result.eslint.env.ESLINT_USE_FLAT_CONFIG)
		equal(vim.env.HOME, result.eslint.env.HOME)
	end
	local result = run(a, "InsertLeave")
	assert(result.eslint and result.gitleaks and not result.typos and not result.biomejs)

	vim.fn.delete(app .. "/eslint.config.cjs")
	write(app .. "/eslint.config.cts", { "export default {}" })
	equal("true", run(a, "BufWritePost").eslint.env.ESLINT_USE_FLAT_CONFIG)
	vim.fn.delete(app .. "/eslint.config.cts")
	write(app .. "/.eslintrc.json", { "{}" })
	equal("false", run(a, "BufEnter").eslint.env.ESLINT_USE_FLAT_CONFIG)
	vim.fn.delete(app .. "/.eslintrc.json")
	write(app .. "/package.json", { '{"eslintConfig": {}}' })
	equal("false", run(a, "BufEnter").eslint.env.ESLINT_USE_FLAT_CONFIG)
	write(app .. "/package.json", { "{}" })
	vim.fn.delete(app .. "/biome.json")
	vim.diagnostic.set(lint.get_namespace("eslint"), a, { { lnum = 0, col = 0, message = "old" } })
	result = run(a, "BufEnter")
	assert(not result.eslint and not result.biomejs)
	equal({}, vim.diagnostic.get(a, { namespace = lint.get_namespace("eslint") }))

	local fresh = open(app .. "/src/new.ts", "typescript")
	result = run(fresh, "BufEnter")
	assert(result.gitleaks and not result.typos)
	vim.bo[fresh].readonly = true
	equal({}, run(fresh, "BufEnter"))
	vim.bo[fresh].readonly = false

	local yaml = open(app .. "/src/config.yaml", "yaml.docker-compose")
	assert(run(yaml, "InsertLeave").yamllint)
	local commit = open(app .. "/COMMIT_EDITMSG", "gitcommit")
	assert(not run(commit, "InsertLeave").gitlint)
	print("lint regression checks passed")
end

local ok, err = xpcall(test, debug.traceback)
vim.fn.delete(tmp, "rf")
if not ok then
	error(err)
end
