return {
	"nvimdev/lspsaga.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	event = { "BufReadPre" },
	keys = {
		{ "<Leader>cr", "<cmd>Lspsaga rename<CR>", desc = "rename" },
		{ "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", desc = "next diagnostic" },
		{ "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", desc = "next diagnostic" },
	},
	opts = {
		lightbulb = {
			enable = false,
		},
	},
}
