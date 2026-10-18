-- Run with nvim --headless -u NONE -i NONE -l tests/nvim/format.lua /path/to/conform.nvim
local root = vim.fn.getcwd()
vim.opt.runtimepath:prepend(root .. "/layat/ydog-1/.config/nvim")
vim.opt.runtimepath:prepend(assert(arg[1], "Pass the pinned conform.nvim checkout"))

local tmp = vim.fn.tempname()
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
	local source = app .. "/src/a.ts"
	write(workspace .. "/node_modules/.bin/prettier", { "#!/bin/sh", "tr '[:lower:]' '[:upper:]'" }, true)
	write(workspace .. "/node_modules/.bin/biome", { "#!/bin/sh", "cat" }, true)
	write(app .. "/.prettierrc", { "{}" })
	write(app .. "/biome.json", { "{}" })
	write(source, { "const x=1" })
	vim.cmd.cd(tmp)
	vim.cmd.edit(source)
	vim.bo.filetype = "typescript"
	local bufnr = vim.api.nvim_get_current_buf()

	local conform = require("conform")
	local opts = dofile(root .. "/layat/ydog-1/.config/nvim/lua/plugins/conform.nvim.lua")[1].opts
	conform.setup(opts)
	equal({ "goimports" }, opts.formatters_by_ft.go)
	local formatters = conform.list_formatters_to_run(bufnr)
	equal("prettier", formatters[1].name)
	equal(1, #formatters)
	equal(workspace .. "/node_modules/.bin/prettier", formatters[1].command)
	equal(app, formatters[1].cwd)
	local saved
	local writes = 0
	vim.api.nvim_create_autocmd("BufWritePost", {
		buffer = bufnr,
		callback = function()
			writes = writes + 1
			saved = vim.fn.readfile(source)
		end,
	})
	vim.cmd.write()
	equal({ "CONST X=1" }, saved)
	equal(saved, vim.api.nvim_buf_get_lines(bufnr, 0, -1, true))
	equal(1, writes)

	vim.fn.delete(app .. "/.prettierrc")
	formatters = conform.list_formatters_to_run(bufnr)
	equal("biome", formatters[1].name)
	equal(workspace .. "/node_modules/.bin/biome", formatters[1].command)
	vim.fn.delete(app .. "/biome.json")
	equal({}, conform.list_formatters_to_run(bufnr))
	write(app .. "/README.md", { "# title" })
	vim.cmd.edit(app .. "/README.md")
	vim.bo.filetype = "markdown"
	local markdown = vim.api.nvim_get_current_buf()
	equal({}, conform.list_formatters_to_run(markdown))
	write(app .. "/.prettierrc", { "{}" })
	formatters = conform.list_formatters_to_run(markdown)
	equal("prettier", formatters[1].name)
	vim.cmd.write()
	equal({ "# TITLE" }, vim.fn.readfile(app .. "/README.md"))
	print("format regression checks passed")
end

local ok, err = xpcall(test, debug.traceback)
vim.fn.delete(tmp, "rf")
if not ok then
	error(err)
end
