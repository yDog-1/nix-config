local set = vim.keymap.set

-- <Leader>をスペースキーに設定
set("", "<Space>", "<Nop>")
vim.g.mapleader = " "

-- jjでノーマルモードに戻る
set("i", "jj", "<Esc>", { silent = true })

-- Alt-j, Alt-k で上下の行と入れ替える
-- 最上、最下の行では何も起こさない
set("n", "<M-j>", function()
	local current_line = vim.api.nvim_win_get_cursor(0)[1]
	local last_line = vim.api.nvim_buf_line_count(0)
	if current_line < last_line then
		vim.cmd("move .+1")
	end
end)
set("n", "<M-k>", function()
	local current_line = vim.api.nvim_win_get_cursor(0)[1]
	if current_line > 1 then
		vim.cmd("move .-2")
	end
end)

-- Leader + n で、ハイライトを消す
set("n", "<Leader>n", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- 折り畳まれた行でもカーソルの移動を直感的に
set({ "n", "v" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
set({ "n", "v" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })

-- Space + Enter で、カーソルの位置で改行
set("n", "<Leader><CR>", "i<CR><Esc>", { desc = "Insert newline from cursor" })

-- Xをブラックホール register に割り当て
set({ "n", "v" }, "x", '"_x')
set({ "n", "v" }, "X", '"_d')

-- Quickfix
set("n", "<Leader>q", "<cmd>copen<CR>", { desc = "Open quickfix" })

vim.api.nvim_create_autocmd("FileType", {
	pattern = "qf",
	callback = function()
		set("n", "q", "<cmd>cclose<CR>", { desc = "Close quickfix", noremap = true, buffer = true })
	end,
})

-- https://zenn.dev/vim_jp/articles/2024-10-07-vim-insert-uppercase
-- 直前に入力した word を大文字に変換
set("i", "<C-k>", function()
	local line = vim.fn.getline(".")
	local col = vim.fn.getpos(".")[3]
	local substring = line:sub(1, col - 1)
	local result = vim.fn.matchstr(substring, [[\v<(\k(<)@!)*$]])
	return "<C-w>" .. result:upper()
end, { expr = true })

-- ターミナルモード
set("t", "<c-]><c-]>", "<C-\\><C-n>", { noremap = true })

-- submode

---[TODO:summary]
---@param mode string|string[]
---@param prefix string
---@param modename string
---@param key string
---@param opts? vim.keymap.set.Opts
local submode = function(mode, prefix, modename, key, opts)
	local submode_map = "<plug>(submode-" .. modename .. ")"
	local rhs = prefix .. key .. submode_map
	set(mode, prefix .. key, rhs, opts)
	-- submode mappings
	set(mode, submode_map .. key, rhs, opts)
end

-- ウィンドウ移動
for _, key in ipairs({
	{
		"<c-h>",
		{ desc = "Focus left window" },
	},
	{
		"<c-j>",
		{ desc = "Focus lower window" },
	},
	{
		"<c-k>",
		{ desc = "Focus upper window" },
	},
	{
		"<c-l>",
		{ desc = "Focus right window" },
	},
	{
		"H",
		{ desc = "Move window to leftmost column" },
	},
	{
		"J",
		{ desc = "Move window to bottom row" },
	},
	{
		"K",
		{ desc = "Move window to top row" },
	},
	{
		"L",
		{ desc = "Move window to rightmost column" },
	},
	{
		"w",
		{ desc = "Cycle to next window" },
	},
	{
		"<c-w>",
		{ desc = "Cycle to next window" },
	},
	{
		"q",
		{ desc = "Close current window" },
	},
	{
		"<c-q>",
		{ desc = "Close current window" },
	},
	{
		"s",
		{ desc = "Split window horizontally" },
	},
	{
		"v",
		{ desc = "Split window vertically" },
	},
	{
		"r",
		{ desc = "Rotate windows forward" },
	},
	{
		"<c-r>",
		{ desc = "Rotate windows forward" },
	},
	{
		"R",
		{ desc = "Rotate windows backward" },
	},
	{
		"x",
		{ desc = "Exchange current window" },
	},
	{
		"<c-x>",
		{ desc = "Exchange current window" },
	},
	{
		"=",
		{ desc = "Equalize window sizes" },
	},
	{
		"-",
		{ desc = "Decrease window height" },
	},
	{
		"+",
		{ desc = "Increase window height" },
	},
	{
		"_",
		{ desc = "Maximize window height" },
	},
	{
		"<",
		{ desc = "Decrease window width" },
	},
	{
		">",
		{ desc = "Increase window width" },
	},
	{
		"|",
		{ desc = "Maximize window width" },
	},
}) do
	submode({ "n", "x" }, "<c-w>", "window", key[1], key[2])
end

-- <C-w>h/j/k/l のウィンドウ移動を無効化
set("n", "<c-w>h", "<Nop>", { desc = "Disable <C-w>h window movement" })
set("n", "<c-w>j", "<Nop>", { desc = "Disable <C-w>j window movement" })
set("n", "<c-w>k", "<Nop>", { desc = "Disable <C-w>k window movement" })
set("n", "<c-w>l", "<Nop>", { desc = "Disable <C-w>l window movement" })
