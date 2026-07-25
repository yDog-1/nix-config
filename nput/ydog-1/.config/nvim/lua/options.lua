local o = vim.opt

-- ヘルプ言語
o.helplang = "ja,en"

-- クリップボードをシステムと共有
o.clipboard = "unnamedplus"

-- スワップファイルを無効
o.swapfile = false

-- インデント・タブの設定
o.tabstop = 2
o.softtabstop = 2
o.shiftwidth = 2
o.expandtab = true
-- 自動でインデントする
o.autoindent = true
o.smartindent = true

-- カーソルが存在する行にハイライト
o.cursorline = true
-- カーソル行、列番号を表示
o.ruler = true
o.number = true
o.relativenumber = true
-- 括弧をハイライト
o.showmatch = true
-- 行番号の表示
o.number = true

-- 補完の設定
o.completeopt = { "menu", "menuone", "noselect" }

-- 検索
o.hlsearch = true
o.incsearch = true
o.ignorecase = true
o.smartcase = true

-- ファイル名の表示
o.laststatus = 3

-- ウィンドウ分割
o.splitbelow = true
o.splitright = true

-- 行の折り返し
o.wrap = true
o.linebreak = true
o.showbreak = ""

-- 折り畳み設定
o.foldmethod = "syntax"
o.foldlevel = 99

-- substitute時に変更箇所をプレビュー
o.inccommand = "split"

-- codexなどの外部ツールでファイルが変更された場合に自動で再読み込み
o.autoread = true
vim.api.nvim_create_autocmd("WinEnter", {
	group = vim.api.nvim_create_augroup("checktime_on_focus", { clear = true }),
	pattern = "*",
	command = "checktime",
})
