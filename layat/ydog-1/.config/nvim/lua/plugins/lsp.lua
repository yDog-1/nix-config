require("plugins.which-key.spec").add({
	mode = { "n", "v" },
	{ "<Leader>c", group = "code" },
})

-- LSP servers available on PATH
local servers = {
	"lua_ls",
	"gopls",
	"golangci_lint_ls",
	"sqls",
	"graphql",
	"jsonls",
	"yamlls",
	"terraformls",
	"taplo",
	"astro",
	"svelte",
	"tailwindcss",
	"nixd",
	"pylsp",
	"gdscript",
	"arduino_language_server",
}

return {
	-- Neovim での LSP 設定を提供
	"neovim/nvim-lspconfig",
	dependencies = {
		"Shougo/ddc-source-lsp",
		"b0o/schemastore.nvim",
	},
	event = { "BufReadPre" },
	config = function()
		local capabilities = require("ddc_source_lsp").make_client_capabilities()

		-- Select the TypeScript server per buffer, independently of the working directory.
		vim.lsp.config("ts_ls", {
			root_dir = function(bufnr, on_dir)
				local root = vim.fs.root(bufnr, { "package.json" })
				if root then
					on_dir(root)
				end
			end,
		})
		vim.lsp.config("denols", {
			root_dir = function(bufnr, on_dir)
				if not vim.fs.root(bufnr, { "package.json" }) then
					on_dir(vim.fs.root(bufnr, { ".git" }) or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)))
				end
			end,
		})
		vim.lsp.enable({ "ts_ls", "denols" })

		---@diagnostic disable-next-line: param-type-mismatch
		vim.lsp.config("*", {
			capabilities = capabilities,
		})

		vim.lsp.enable(servers)
	end,
}
