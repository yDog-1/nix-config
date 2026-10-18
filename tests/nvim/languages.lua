-- Args: conform.nvim checkout, nvim-lint checkout, Ruff executable.
local root = vim.fn.getcwd()
vim.opt.runtimepath:prepend(root .. "/layat/ydog-1/.config/nvim")
vim.opt.runtimepath:prepend(assert(arg[1], "Pass the pinned conform.nvim checkout"))
vim.opt.runtimepath:prepend(assert(arg[2], "Pass the pinned nvim-lint checkout"))
vim.env.PATH = vim.fs.dirname(assert(arg[3], "Pass the Ruff executable")) .. ":" .. vim.env.PATH

local tmp = "/tmp/opencode/neovim-language-test-" .. vim.uv.os_getpid()
local function equal(expected, actual)
	assert(vim.deep_equal(expected, actual), "expected " .. vim.inspect(expected) .. ", got " .. vim.inspect(actual))
end

local function test()
	vim.fn.mkdir(tmp .. "/project/src", "p")
	vim.fn.writefile(
		{ "line-length = 88", "[lint]", 'select = ["F"]', 'ignore = ["F401"]' },
		tmp .. "/project/ruff.toml"
	)
	vim.fn.writefile({ "import os", "answer=missing" }, tmp .. "/project/src/main.py")
	vim.cmd.cd(tmp)
	vim.cmd.edit(tmp .. "/project/src/main.py")
	vim.bo.filetype = "python"
	local bufnr = vim.api.nvim_get_current_buf()
	local conform = require("conform")
	conform.setup(dofile(root .. "/layat/ydog-1/.config/nvim/lua/plugins/conform.nvim.lua")[1].opts)
	local err
	conform.format({ async = false }, function(format_err)
		err = format_err
	end)
	assert(not err, err)
	equal({ "import os", "", "answer = missing" }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, true))
	-- Lint unsaved content, with the project's Ruff configuration applied.
	dofile(root .. "/layat/ydog-1/.config/nvim/lua/plugins/nvim-lint.lua")[1].config()
	local lint = require("lint")
	local original = lint.try_lint
	lint.try_lint = function(name, opts)
		if name == "ruff" then
			original(name, opts)
		end
	end
	vim.api.nvim_exec_autocmds("InsertLeave", { group = "ydog.lint", buffer = bufnr })
	assert(
		vim.wait(5000, function()
			return #vim.diagnostic.get(bufnr, { namespace = lint.get_namespace("ruff") }) > 0
		end),
		"Ruff did not publish a diagnostic"
	)
	local diagnostics = vim.diagnostic.get(bufnr, { namespace = lint.get_namespace("ruff") })
	equal(1, #diagnostics)
	equal("F821", diagnostics[1].code)
	equal(2, diagnostics[1].lnum)
	local plugins = dofile(root .. "/layat/ydog-1/.config/nvim/after/lsp/pylsp.lua").settings.pylsp.plugins
	for _, config in pairs(plugins) do
		equal(false, config.enabled)
	end
	print("language integration checks passed")
end

local ok, err = xpcall(test, debug.traceback)
vim.fn.delete(tmp, "rf")
if not ok then
	error(err)
end
