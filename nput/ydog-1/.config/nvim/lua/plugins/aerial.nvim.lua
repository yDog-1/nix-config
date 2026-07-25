return {
	"https://github.com/stevearc/aerial.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	keys = {
		{ "<leader>co", "<cmd>AerialToggle!<CR>", desc = "Toggle Aerial Outline" },
	},
	opts = {
		on_attach = function(bufnr)
			-- Jump to symbol under cursor
			vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr, desc = "Aerial Prev Symbol" })
			vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr, desc = "Aerial Next Symbol" })
		end,
	},
}
