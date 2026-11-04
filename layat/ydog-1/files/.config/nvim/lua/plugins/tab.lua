require("plugins.which-key.spec").add({
	mode = "n",
	{ "<c-t>", group = "tab" },
})

vim.keymap.set("n", "<c-t>n", "<cmd>tabnew<cr>", { desc = "new tab" })
vim.keymap.set("n", "<c-t>q", "<cmd>tabclose<cr>", { desc = "close tab" })
vim.keymap.set("n", "<c-t>o", "<cmd>tabonly<cr>", { desc = "close other tabs" })
vim.keymap.set("n", "<c-t>l", "<cmd>tabnext<cr>", { desc = "next tab" })
vim.keymap.set("n", "<c-t><c-t>", "<cmd>tabnext<cr>", { desc = "next tab" })
vim.keymap.set("n", "<c-t>h", "<cmd>tabprevious<cr>", { desc = "previous tab" })

local function get_window_options(win)
	local result = {}

	for name, info in pairs(vim.api.nvim_get_all_options_info()) do
		if info.scope == "win" then
			local ok, value = pcall(vim.api.nvim_get_option_value, name, { win = win })
			if ok then
				result[name] = value
			end
		end
	end

	return result
end

local function set_window_options(win, options)
	for name, value in pairs(options) do
		pcall(vim.api.nvim_set_option_value, name, value, { win = win })
	end
end

local function move_window_to_tab(direction)
	local source_win = vim.api.nvim_get_current_win()
	local source_buf = vim.api.nvim_win_get_buf(source_win)
	local source_options = get_window_options(source_win)
	local source_view = vim.fn.winsaveview()
	local tabs = vim.api.nvim_list_tabpages()
	local current_tab = vim.api.nvim_get_current_tabpage()
	local current_index

	for index, tab in ipairs(tabs) do
		if tab == current_tab then
			current_index = index
			break
		end
	end

	local target_tab = tabs[current_index + direction]

	if target_tab then
		vim.api.nvim_set_current_tabpage(target_tab)
		vim.cmd.sbuffer(source_buf)
	else
		if direction > 0 then
			vim.cmd.tabnew()
		else
			vim.cmd("0tabnew")
		end
		vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), source_buf)
		target_tab = vim.api.nvim_get_current_tabpage()
	end

	local target_win = vim.api.nvim_get_current_win()
	set_window_options(target_win, source_options)
	vim.fn.winrestview(source_view)

	vim.api.nvim_set_current_win(source_win)
	vim.cmd.close()

	if vim.api.nvim_tabpage_is_valid(target_tab) then
		vim.api.nvim_set_current_tabpage(target_tab)
	end
end

vim.keymap.set("n", "<c-t>>", function()
	move_window_to_tab(1)
end, { desc = "move window to next tab" })
vim.keymap.set("n", "<c-t><", function()
	move_window_to_tab(-1)
end, { desc = "move window to previous tab" })

return {
	{
		-- tabごとにbufferを表示してくれる
		"tiagovla/scope.nvim",
		lazy = false,
		opts = {},
	},
}
