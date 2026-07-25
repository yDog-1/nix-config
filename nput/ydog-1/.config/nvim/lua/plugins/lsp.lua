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

		-- ts_ls denols
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
			callback = function()
				if vim.fn.findfile("package.json", ".;") ~= "" then
					vim.lsp.enable("ts_ls")
					vim.lsp.enable("denols", false)
				else
					vim.lsp.enable("denols")
					vim.lsp.enable("ts_ls", false)
				end
			end,
		})

		---@diagnostic disable-next-line: param-type-mismatch
		vim.lsp.config("*", {
			capabilities = capabilities,
		})

		vim.lsp.enable(servers)
	end,
}
