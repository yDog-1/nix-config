-- CTRL-A, CTRL-X の強化
return {
	"monaqa/dial.nvim",
	event = "BufReadPost",
	keys = {
		{
			"<C-a>",
			function()
				require("dial.map").manipulate("increment", "normal")
			end,
			desc = "Increment",
		},
		{
			"<C-x>",
			function()
				require("dial.map").manipulate("decrement", "normal")
			end,
			desc = "Decrement",
		},
		{
			"g<C-a>",
			function()
				require("dial.map").manipulate("increment", "gnormal")
			end,
			desc = "Increment",
		},
		{
			"g<C-x>",
			function()
				require("dial.map").manipulate("decrement", "gnormal")
			end,
			desc = "Decrement",
		},
		{
			"<C-a>",
			function()
				require("dial.map").manipulate("increment", "visual")
			end,
			mode = "v",
			desc = "Increment",
		},
		{
			"<C-x>",
			function()
				require("dial.map").manipulate("decrement", "visual")
			end,
			mode = "v",
			desc = "Decrement",
		},
		{
			"g<C-a>",
			function()
				require("dial.map").manipulate("increment", "gvisual")
			end,
			mode = "v",
			desc = "Increment",
		},
		{
			"g<C-x>",
			function()
				require("dial.map").manipulate("decrement", "gvisual")
			end,
			mode = "v",
			desc = "Decrement",
		},
	},
	config = function()
		local augend = require("dial.augend")
		local config = require("dial.config")
		local default = require("dial.config").augends:get("default")
		config.augends:register_group({
			default = vim.list_extend(default, {
				augend.constant.alias.bool,
			}),
		})
		config.augends:on_filetype({
			markdown = {
				augend.misc.alias.markdown_header,
			},
		})
	end,
}
