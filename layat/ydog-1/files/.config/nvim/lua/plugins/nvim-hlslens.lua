-- 検索数表示
return {
	"kevinhwang91/nvim-hlslens",
	keys = {
		{
			"n",
			[[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
			desc = "Search next",
		},
		{
			"N",
			[[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
			desc = "Search previous",
		},
		{
			"*",
			[[*<Cmd>lua require('hlslens').start()<CR>]],
			desc = "Search word under cursor",
		},
		{
			"#",
			[[#<Cmd>lua require('hlslens').start()<CR>]],
			desc = "Search word under cursor backward",
		},
		{
			"g*",
			[[g*<Cmd>lua require('hlslens').start()<CR>]],
			desc = "Search word under cursor (whole word)",
		},
		{
			"g#",
			[[g#<Cmd>lua require('hlslens').start()<CR>]],
			desc = "Search word under cursor backward (whole word)",
		},
	},
	opts = {},
}
