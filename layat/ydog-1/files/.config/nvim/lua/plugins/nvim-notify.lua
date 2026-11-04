return {
	"rcarriga/nvim-notify",
	config = function()
		---@diagnostic disable-next-line: assign-type-mismatch
		vim.notify = require("notify")
	end,
}
