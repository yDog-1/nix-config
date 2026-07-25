---Check if any of the given files exist in the current directory or any of its parent directories.
---@param config_files string[]
---@return boolean
local is_file_exist = function(config_files)
	for _, config_file in ipairs(config_files) do
		if vim.fn.findfile(config_file, ".;") ~= "" then
			return true
		end
	end
	return false
end

local is_biome_file_exist = function()
	local config_files = {
		".biome.json",
		".biome.jsonc",
		"biome.json",
		"biome.jsonc",
	}
	return is_file_exist(config_files)
end

local is_eslint_file_exist = function()
	local config_files = {
		".eslintrc",
		"eslint.config.js",
		"eslint.config.mjs",
		"eslitn.config.cjs",
		"eslint.config.ts",
		"eslint.config.mts",
		"eslitn.config.cts",
	}
	return is_file_exist(config_files)
end

---@param bufnr? integer
---@return boolean
local is_editing_file = function(bufnr)
	local buffer = bufnr or vim.api.nvim_get_current_buf()

	if vim.bo[buffer].buftype ~= "" then
		return false
	end

	if vim.api.nvim_buf_get_name(buffer) == "" then
		return false
	end

	if not vim.bo[buffer].modifiable then
		return false
	end

	if vim.bo[buffer].readonly then
		return false
	end

	return true
end

---Create an autocmd to run the linter on buffer enter and after writing the buffer.
---@param linter? string
---@param bufnr? integer
local create_lint_autocmd = function(linter, bufnr)
	local buffer = bufnr or nil
	vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
		buffer = buffer,
		group = vim.api.nvim_create_augroup("ydog.lint." .. (linter or "default"), { clear = true }),
		callback = function(ctx)
			if not is_editing_file(ctx.buf) then
				return
			end

			require("lint").try_lint(linter, { ignore_errors = true })
		end,
	})
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
				go = { "golangcilint" },
			}

			-- enable auto linting with defined filetypes by `lint.linters_by_ft`
			create_lint_autocmd()

			-- for all filetypes
			create_lint_autocmd("typos")
			create_lint_autocmd("gitleaks")

			-- for js/ts filetypes
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
				group = vim.api.nvim_create_augroup("ydog.lint-js", { clear = true }),
				callback = function(ctx)
					if is_biome_file_exist() then
						create_lint_autocmd("biomejs", ctx.buf)
						return
					end
					if is_eslint_file_exist() then
						create_lint_autocmd("eslint", ctx.buf)
						return
					end
				end,
			})
		end,
	},
}
