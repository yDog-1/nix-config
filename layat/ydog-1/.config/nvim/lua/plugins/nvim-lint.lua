local project = require("ydog-1.project")

local web_filetypes = {
	javascript = true,
	javascriptreact = true,
	typescript = true,
	typescriptreact = true,
}

local config_files = {
	gitlint = { ".gitlint" },
	gitleaks = { ".gitleaks.toml" },
	hadolint = { ".hadolint.yaml", ".hadolint.yml" },
	yamllint = { ".yamllint", ".yamllint.yaml", ".yamllint.yml" },
	markdownlint = {
		".markdownlint.json",
		".markdownlint.jsonc",
		".markdownlint.yaml",
		".markdownlint.yml",
		".markdownlint.cjs",
	},
	typos = { "typos.toml", "_typos.toml", ".typos.toml" },
	ruff = { "ruff.toml", ".ruff.toml", "pyproject.toml" },
}

local function is_editing_file(bufnr)
	return vim.bo[bufnr].buftype == ""
		and vim.api.nvim_buf_get_name(bufnr) ~= ""
		and vim.bo[bufnr].modifiable
		and not vim.bo[bufnr].readonly
end

local function run_lint(ctx)
	if not is_editing_file(ctx.buf) then
		return
	end

	local lint = require("lint")
	local ft = vim.bo[ctx.buf].filetype
	local names = vim.deepcopy(lint.linters_by_ft[ft] or {})
	if not lint.linters_by_ft[ft] then
		for _, part in ipairs(vim.split(ft, ".", { plain = true })) do
			vim.list_extend(names, lint.linters_by_ft[part] or {})
		end
	end
	vim.list_extend(names, { "typos", "gitleaks" })

	local biome_root, eslint_root, eslint_legacy
	if web_filetypes[ft] then
		biome_root = project.config_root(ctx.buf, project.biome_configs)
		eslint_root, eslint_legacy = project.eslint_root(ctx.buf)
		for name, root in pairs({ biomejs = biome_root, eslint = eslint_root }) do
			if root then
				names[#names + 1] = name
			end
		end
		-- A removed config must also clear the previous diagnostics.
		if not biome_root then
			vim.diagnostic.reset(lint.get_namespace("biomejs"), ctx.buf)
		end
		if not eslint_root then
			vim.diagnostic.reset(lint.get_namespace("eslint"), ctx.buf)
		end
	end

	vim.api.nvim_buf_call(ctx.buf, function()
		for _, name in ipairs(names) do
			local command = (name == "biomejs" or name == "eslint")
				and project.node_command(ctx.buf, name == "biomejs" and "biome" or "eslint")
			local cwd = (name == "biomejs" and biome_root)
				or (name == "eslint" and eslint_root)
				or (config_files[name] and project.config_root(ctx.buf, config_files[name]))
				or project.root(ctx.buf)
			lint.try_lint(name, {
				cwd = cwd,
				filter = function(linter)
					-- gitlint's --msg-filename reads the saved message even though
					-- its upstream definition declares stdin support.
					local reads_buffer = linter.stdin and name ~= "gitlint"
					if
						(ctx.event == "InsertLeave" and not reads_buffer)
						or (not reads_buffer and vim.fn.filereadable(vim.api.nvim_buf_get_name(ctx.buf)) == 0)
					then
						return false
					end
					if command and vim.fn.executable(command) == 0 then
						vim.notify_once("Linter not found: " .. command .. " (" .. cwd .. ")", vim.log.levels.WARN)
						return false
					end
					return true
				end,
				wrap_linter = function(linter)
					if name == "biomejs" or name == "eslint" then
						linter.cmd = command
						if name == "eslint" then
							linter.env = vim.tbl_extend("force", vim.fn.environ(), linter.env or {}, {
								ESLINT_USE_FLAT_CONFIG = eslint_legacy and "false" or "true",
							})
						end
					end
					return linter
				end,
			})
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
			vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
				group = vim.api.nvim_create_augroup("ydog.lint", { clear = true }),
				callback = run_lint,
			})
		end,
	},
}
