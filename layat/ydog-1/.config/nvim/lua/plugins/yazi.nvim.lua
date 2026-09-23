return {
	{
		"mikavilpas/yazi.nvim",
		version = "*",
		event = "VeryLazy",
		dependencies = {
			{ "nvim-lua/plenary.nvim" },
		},
		keys = {
			{
				"<leader><leader>",
				mode = { "n", "v" },
				"<cmd>Yazi cwd<cr>",
				desc = "Open yazi in cwd",
			},
		},
		---@module 'yazi'
		---@type YaziConfig | {}
		opts = {
			open_for_directories = false,
			keymaps = {
				show_help = "<f1>",
			},
		},
	},
}
