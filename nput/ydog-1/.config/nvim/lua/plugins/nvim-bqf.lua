return {
	{
		"kevinhwang91/nvim-bqf",
		lazy = true,
		ft = "qf",
		opts = function()
			-- Float を透明化
			vim.cmd.highlight({ "link", "BqfPreviewBorder", "NONE" })
			vim.cmd.highlight({ "BqfPreviewBorder", "ctermbg=none", "guibg=none", bang = true })

			return {
				preview = {
					winblend = 0,
				},
			}
		end,
	},
}
