return {
	"https://github.com/kamecha/bimove",
	keys = {
		{ "M", "<Plug>(bimove-enter)<Plug>(bimove)", mode = { "n", "v" }, desc = "Enter BiMove mode" },
		{
			"<Plug>(bimove)H",
			"<Plug>(bimove-high)<Plug>(bimove)",
			mode = { "n", "v" },
			desc = "Move to the highest position",
		},
		{
			"<Plug>(bimove)L",
			"<Plug>(bimove-low)<Plug>(bimove)",
			mode = { "n", "v" },
			desc = "Move to the lowest position",
		},
	},
	config = function()
		vim.cmd([[highlight link BimoveHigh Search]])
		vim.cmd([[highlight link BimoveCursor IncSearch]])
		vim.cmd([[highlight link BimoveLow IncSearch]])
	end,
}
