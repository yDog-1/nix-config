local web_filetypes = {
	javascript = true,
	javascriptreact = true,
	typescript = true,
	typescriptreact = true,
}

local eslint_flat_configs = {
	"eslint.config.js",
	"eslint.config.mjs",
	"eslint.config.cjs",
	"eslint.config.ts",
	"eslint.config.mts",
	"eslint.config.cts",
}
local eslint_legacy_configs =
	{ ".eslintrc", ".eslintrc.js", ".eslintrc.cjs", ".eslintrc.json", ".eslintrc.yaml", ".eslintrc.yml" }

local function is_eslint_config(name, path)
	if vim.tbl_contains(eslint_flat_configs, name) or vim.tbl_contains(eslint_legacy_configs, name) then
		return true
	end
	if name ~= "package.json" then
		return false
	end
	local ok, package = pcall(function()
		return vim.json.decode(table.concat(vim.fn.readfile(vim.fs.joinpath(path, name)), "\n"))
	end)
	return ok and type(package) == "table" and type(package.eslintConfig) == "table"
end

local function uses_legacy_eslint(root)
	for _, name in ipairs(eslint_flat_configs) do
		if vim.fn.filereadable(vim.fs.joinpath(root, name)) == 1 then
			return false
		end
	end
	return true
end

local function node_command(bufnr, name)
	local dirname = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
	for _, dir in ipairs(vim.fs.find("node_modules", { path = dirname, upward = true, limit = math.huge })) do
		local command = vim.fs.joinpath(dir, ".bin", name)
		if vim.fn.executable(command) == 1 then
			return command
		end
	end
	return name
end

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

local function run_web_linter(name, root, bufnr, opts)
	local lint = require("lint")
	if not root then
		vim.diagnostic.reset(lint.get_namespace(name), bufnr)
		return
	end
	if opts.filter == "stdin" and not lint.linters[name].stdin then
		return
	end
	local command = node_command(bufnr, name == "biomejs" and "biome" or "eslint")
	if vim.fn.executable(command) == 0 then
		vim.notify_once("Linter not found: " .. command .. " (" .. root .. ")", vim.log.levels.WARN)
		return
	end
	lint.try_lint(
		name,
		vim.tbl_extend("force", opts, {
			cwd = root,
			wrap_linter = function(linter)
				linter.cmd = command
				if name == "eslint" then
					-- nvim-lint's env replaces the entire process environment.
					linter.env = vim.tbl_extend("force", vim.fn.environ(), linter.env or {}, {
						ESLINT_USE_FLAT_CONFIG = uses_legacy_eslint(root) and "false" or "true",
					})
				end
				return linter
			end,
		})
	)
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
			local biome_root = vim.fs.root(ctx.buf, { "biome.json", "biome.jsonc", ".biome.json", ".biome.jsonc" })
			run_web_linter("biomejs", biome_root, ctx.buf, opts)
			run_web_linter("eslint", vim.fs.root(ctx.buf, is_eslint_config), ctx.buf, opts)
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
