local function lsp_clients()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	if next(clients) == nil then
		return "LSPなし"
	end
	local client_names = {}
	for _, client in pairs(clients) do
		table.insert(client_names, client.name)
	end
	return table.concat(client_names, " | ")
end

return {
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				icons_enabled = true,
				theme = "modus-vivendi",
				disabled_filetypes = {
					"neo-tree",
				},
				section_separators = { left = "", right = "" },
				component_separators = { left = "|", right = "|" },
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diagnostics" },
				lualine_c = { "filename", "filetype" },
				lualine_x = {},
				lualine_y = { lsp_clients },
				lualine_z = { "progress" },
			},
			tabline = {},
			winbar = {},
			inactive_winbar = {},
			extensions = {},
		},
	},
}
