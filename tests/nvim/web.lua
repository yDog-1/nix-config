-- Args: conform.nvim checkout, nvim-lint checkout, Prettier, Biome and ESLint executables.
local root = vim.fn.getcwd()
vim.opt.runtimepath:prepend(root .. "/layat/ydog-1/.config/nvim")
vim.opt.runtimepath:prepend(assert(arg[1], "Pass the pinned conform.nvim checkout"))
vim.opt.runtimepath:prepend(assert(arg[2], "Pass the pinned nvim-lint checkout"))
local tmp = vim.fn.tempname()

local function test()
	local workspace = tmp .. "/workspace"
	local app = workspace .. "/packages/app"
	vim.fn.mkdir(app .. "/src", "p")
	vim.fn.mkdir(workspace .. "/node_modules/.bin", "p")
	for i, name in ipairs({ "prettier", "biome", "eslint" }) do
		assert(
			vim.uv.fs_symlink(
				assert(arg[i + 2], "Pass the " .. name .. " executable"),
				workspace .. "/node_modules/.bin/" .. name
			)
		)
	end
	vim.fn.writefile({ "{}" }, app .. "/.prettierrc")
	vim.fn.writefile({ 'module.exports = [{ rules: { "no-console": "error" } }]' }, app .. "/eslint.config.cjs")
	vim.fn.writefile({
		'{"linter":{"enabled":true,"rules":{"recommended":false,"suspicious":{"noDoubleEquals":"error"}}}}',
	}, app .. "/biome.json")
	local source = app .. "/src/main.js"
	vim.fn.writefile({ "var answer=1", "if(answer==1){console.log(answer)}" }, source)
	vim.cmd.cd(tmp)
	vim.cmd.edit(source)
	vim.bo.filetype = "javascript"
	local bufnr = vim.api.nvim_get_current_buf()
	local conform = require("conform")
	conform.setup(dofile(root .. "/layat/ydog-1/.config/nvim/lua/plugins/conform.nvim.lua")[1].opts)
	dofile(root .. "/layat/ydog-1/.config/nvim/lua/plugins/nvim-lint.lua")[1].config()
	local lint = require("lint")
	local original = lint.try_lint
	lint.try_lint = function(name, opts)
		if name == "eslint" or name == "biomejs" then
			original(name, opts)
		end
	end
	vim.cmd.write()
	assert(vim.fn.readfile(source)[1] == "var answer = 1;", "Prettier did not format before saving")
	local function diagnostics(name)
		return vim.diagnostic.get(bufnr, { namespace = lint.get_namespace(name) })
	end
	assert(
		vim.wait(10000, function()
			return #diagnostics("eslint") > 0 and #diagnostics("biomejs") > 0
		end),
		"Expected both ESLint and Biome diagnostics: " .. vim.inspect(vim.diagnostic.get(bufnr))
	)
	assert(diagnostics("eslint")[1].code == "no-console")
	assert(diagnostics("biomejs")[1].code == "lint/suspicious/noDoubleEquals")
	-- Only ESLint can see this unsaved change; Biome reads the saved file.
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, { "var answer = 1;" })
	vim.api.nvim_exec_autocmds("InsertLeave", { group = "ydog.lint", buffer = bufnr })
	assert(
		vim.wait(10000, function()
			return #diagnostics("eslint") == 0
		end),
		"ESLint did not lint unsaved content"
	)
	assert(#diagnostics("biomejs") > 0)
	print("web integration checks passed")
end

local ok, err = xpcall(test, debug.traceback)
vim.fn.delete(tmp, "rf")
if not ok then
	error(err)
end
