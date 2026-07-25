local function lazygit_toggle()
	local Terminal = require("toggleterm.terminal").Terminal
	local lazygit = Terminal:new({
		cmd = "lazygit",
		direction = "float",
		hidden = true,
		on_open = function()
			vim.keymap.set("t", "<c-[><c-[>", "<esc>", { buffer = 0 })
			vim.cmd("startinsert")
		end,
	})
	lazygit:toggle()
end

return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		keys = {
			{ "<leader>gG", lazygit_toggle, silent = true, desc = "Lazygit" },
			{ [[<C-\>]], desc = "Toggle terminal" },
			{ [[<C-¥>]], desc = "Toggle terminal" },
		},
		opts = {
			direction = "horizontal",
			open_mapping = { [[<c-\>]], [[<c-¥>]] },
		},
	},
}
