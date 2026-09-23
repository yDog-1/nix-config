return {
	{
		"https://github.com/rebelot/kanagawa.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("kanagawa").setup({
				transparent = true,
				colors = {
					theme = {
						all = {
							ui = {
								bg_gutter = "none",
							},
						},
					},
				},
				overrides = function(colors)
					local palette_colors = colors.palette
					return {
						NormalFloat = { bg = "none" },
						FloatBorder = { fg = palette_colors.fujiWhite, bg = "none" },
						FloatTitle = { bg = "none" },
						Pmenu = { bg = "none" },
						CursorLine = { bg = palette_colors.sumiInk5 },
					}
				end,
			})
			vim.cmd.colorscheme("kanagawa")
		end,
	},
}
