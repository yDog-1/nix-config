return {
	"shellRaining/hlchunk.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		chunk = {
			enable = true,
			duration = 0,
			delay = 0,
		},
		indent = {
			enable = true,
			delay = 0,
		},
	},
}
