return {
	{
		"https://github.com/catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "mocha",
				transparent_background = true,
				custom_highlights = function(colors)
					return {
						SignColumn = { bg = "none" },
						LineNr = { fg = "#949494" },
						CursorLineNr = { fg = "#c0c0c0", bold = true },
						NormalFloat = { bg = "none" },
						FloatBorder = { fg = colors.text, bg = "none" },
						FloatTitle = { bg = "none" },
						Pmenu = { bg = "none" },
						CursorLine = { bg = colors.surface0 },
						Visual = { fg = colors.crust, bg = colors.rosewater },
					}
				end,
				lsp_styles = {
					underlines = {
						errors = { "undercurl" },
						hints = { "undercurl" },
						warnings = { "undercurl" },
						information = { "undercurl" },
						ok = { "undercurl" },
					},
				},
			})
			vim.cmd.colorscheme("catppuccin-mocha")
		end,
	},
}
