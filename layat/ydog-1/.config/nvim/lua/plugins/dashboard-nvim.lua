return {
	"nvimdev/dashboard-nvim",
	event = "VimEnter",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	keys = {
		{ "<leader>.", "<cmd>Dashboard<CR>", desc = "Dashboard" },
	},
	opts = {
		theme = "doom",
		config = {
			center = {
				{
					icon = "  ",
					desc = "Find File",
					desc_hl = "DiagnosticInfo",
					key = "f",
					key_hl = "DiagnosticInfo",
					action = function()
						vim.fn["ddu#start"]({ name = "file" })
					end,
				},
				{
					icon = "  ",
					desc = "New File",
					desc_hl = "String",
					key = "n",
					key_hl = "String",
					action = "ene | startinsert",
				},
				{
					icon = "  ",
					desc = "Live Grep",
					desc_hl = "DiagnosticWarn",
					key = "g",
					key_hl = "DiagnosticWarn",
					action = function()
						vim.fn["ddu#start"]({ name = "rg" })
					end,
				},
				{
					icon = "  ",
					desc = "Recent Files",
					desc_hl = "Comment",
					key = "r",
					key_hl = "Comment",
					action = function()
						vim.fn["ddu#start"]({ name = "recent_file" })
					end,
				},
				{
					icon = "󰒲  ",
					desc = "Lazy",
					desc_hl = "DiagnosticHint",
					key = "L",
					key_hl = "DiagnosticHint",
					action = "Lazy",
				},
				{
					icon = "  ",
					desc = "Browse Repo",
					desc_hl = "Function",
					key = "x",
					key_hl = "Function",
					action = "GinBrowse ++repository",
				},
				{
					icon = "  ",
					desc = "Git Status",
					desc_hl = "DiagnosticInfo",
					key = "s",
					key_hl = "DiagnosticInfo",
					action = function()
						vim.fn["ddu#start"]({ name = "git_status" })
					end,
				},
				{
					icon = "  ",
					desc = "Quit",
					desc_hl = "DiagnosticError",
					key = "q",
					key_hl = "DiagnosticError",
					action = "qa",
				},
			},
			footer = {},
		},
	},
}
