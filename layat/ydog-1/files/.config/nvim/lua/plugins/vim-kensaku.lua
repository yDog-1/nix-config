return {
	-- 日本語をローマ字で検索
	"lambdalisue/vim-kensaku",
	dependencies = {
		"vim-denops/denops.vim",
	},
	lazy = true,
	config = function()
		require("denops-lazy").load("vim-kensaku", { wait_load = false })
	end,
}
