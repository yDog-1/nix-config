vim.g.chezmoidir = os.getenv("HOME") .. "/.local/share/chezmoi"

return {
	"xvzc/chezmoi.nvim",
	lazy = true,
	cmd = {
		"ChezmoiReAdd",
	},
	-- chezmoiのファイルを開いたらこのプラグインを読み込む
	event = "BufReadPre " .. vim.g.chezmoidir .. "/*",
	opts = function()
		-- chezmoiのファイルを開いたら編集モードにする
		vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
			pattern = { vim.g.chezmoidir .. "/*" },
			callback = function(ev)
				local bufnr = ev.buf
				local edit_watch = function()
					-- バッファが有効かチェック
					if vim.api.nvim_buf_is_valid(bufnr) then
						require("chezmoi.commands.__edit").watch(bufnr)
					end
				end
				-- より安全なタイミングで実行
				vim.defer_fn(edit_watch, 100) -- 100ms後に実行
			end,
		})

		-- ChezmoiReAdd コマンドを作成
		vim.api.nvim_create_user_command("ChezmoiReAdd", function()
			vim.fn.system("chezmoi re-add")
			vim.notify("Executed: chezmoi re-add", vim.log.levels.INFO)
		end, { desc = "Execute chezmoi re-add" })

		return {
			edit = {
				watch = true,
			},
		}
	end,
}
