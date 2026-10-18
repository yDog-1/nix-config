local web_filetypes = {
	javascript = true,
	javascriptreact = true,
	typescript = true,
	typescriptreact = true,
}

local function is_editing_file(bufnr)
	return vim.bo[bufnr].buftype == ""
		and vim.api.nvim_buf_get_name(bufnr) ~= ""
		and vim.bo[bufnr].modifiable
		and not vim.bo[bufnr].readonly
end

local function lint_options(ctx)
	local filename = vim.api.nvim_buf_get_name(ctx.buf)
	return {
		-- Use the buffer's project, leaving config discovery to each CLI.
		cwd = vim.fs.root(ctx.buf, { ".git" }) or vim.fs.dirname(filename),
		filter = (ctx.event == "InsertLeave" or vim.fn.filereadable(filename) == 0) and "stdin" or nil,
	}
end

local function run_web_linter(name, bufnr, opts)
	local lint = require("lint")
	local cwd = vim.fn.getcwd()
	local command = vim.fs.joinpath(cwd, "node_modules", ".bin", name == "biomejs" and "biome" or "eslint")
	-- Only use project-local tools; let the built-in linter resolve the command.
	if vim.fn.executable(command) == 0 then
		vim.diagnostic.reset(lint.get_namespace(name), bufnr)
		return
	end
	lint.try_lint(name, vim.tbl_extend("force", opts, { cwd = cwd }))
end

local function run_lint(ctx)
	if not is_editing_file(ctx.buf) then
		return
	end
	vim.api.nvim_buf_call(ctx.buf, function()
		local lint = require("lint")
		local opts = lint_options(ctx)
		lint.try_lint(nil, opts)
		lint.try_lint({ "typos", "gitleaks" }, opts)
		if web_filetypes[vim.bo[ctx.buf].filetype] then
			run_web_linter("biomejs", ctx.buf, opts)
			run_web_linter("eslint", ctx.buf, opts)
		end
	end)
end

return {
	{
		"https://github.com/mfussenegger/nvim-lint",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			local lint = require("lint")
			lint.linters_by_ft = {
				gitcommit = { "gitlint" },
				dockerfile = { "hadolint" },
				yaml = { "yamllint" },
				markdown = { "markdownlint" },
				python = { "ruff" },
			}
			-- --msg-filename reads the saved message, not stdin.
			lint.linters.gitlint.stdin = false
			lint.linters.gitlint.append_fname = false
			vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
				group = vim.api.nvim_create_augroup("ydog.lint", { clear = true }),
				callback = run_lint,
			})
		end,
	},
}
