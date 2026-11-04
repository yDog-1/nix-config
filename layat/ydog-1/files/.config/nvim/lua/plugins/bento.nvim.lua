return {
	"https://github.com/serhez/bento.nvim",
	keys = {
		{
			";",
		},
	},
	opts = {
		ui = {
			floating = {
				-- position = "middle-left",
				-- 中央に表示 20は調整用
				offset_x = -vim.o.columns / 2 + 20,
			},
		},
		actions = {
			copy_path = {
				key = "y",
				action = function(_, buf_name)
					vim.fn.setreg("+", buf_name)
				end,
			},
		},
	},
}
