---@type vim.lsp.Config
return {
	cmd = { "arduino-language-server" },
	filetypes = { "arduino" },
	root_dir = function(bufnr, on_dir)
		local root = vim.fs.root(bufnr, "sketch.yaml")
		if root then
			on_dir(root)
		end
	end,
	on_init = function(client)
		client.server_capabilities.documentSymbolProvider = nil
		client.server_capabilities.signatureHelpProvider = nil
	end,
	capabilities = {
		textDocument = {
			completion = {
				completionItem = {
					additionalTextEditsSupport = false,
					snippetSupport = false,
				},
			},
			---@diagnostic disable-next-line: assign-type-mismatch
			semanticTokens = vim.NIL,
		},
		workspace = {
			---@diagnostic disable-next-line: assign-type-mismatch
			semanticTokens = vim.NIL,
		},
	},
}
