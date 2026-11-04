return {
	"cohama/lexima.vim",
	event = "InsertEnter",
	init = function()
		vim.g.lexima_ctrlh_as_backspace = 1
		vim.g.lexima_no_default_rules = 1
	end,
}
