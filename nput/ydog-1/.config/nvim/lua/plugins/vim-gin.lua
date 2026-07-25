require("plugins.which-key.spec").add({
	mode = { "n", "v" },
	{ "<Leader>g", group = "Git" },
})

require("plugins.which-key.spec").add({
	mode = "n",
	{ "<C-g>", proxy = "<Leader>g" },
})

require("plugins.which-key.spec").add({
	mode = "n",
	{ "<Leader>gb", group = "B~" },
})

function git_commit_with_diff()
	-- tab を開いて、上に diff、下に commit メッセージ入力欄を表示
	vim.cmd([[tabnew]])
	vim.cmd([[GinDiff --staged]])
	vim.cmd.Gin("commit")
	-- autocmdで、Commitウィンドウを閉じたときにtabも閉じるようにする
	local commit_group = vim.api.nvim_create_augroup("CommitCloseTab", { clear = true })
	vim.api.nvim_create_autocmd("BufUnload", {
		pattern = "*COMMIT_EDITMSG",
		group = commit_group,
		callback = function()
			vim.cmd([[tabclose]])
			vim.api.nvim_del_augroup_by_id(commit_group)
		end,
	})
end

return {
	"lambdalisue/vim-gin",
	lazy = true,
	dependencies = {
		"vim-denops/denops.vim",
	},
	cmd = {
		"Gin",
		"GinBlame",
		"GinBuffer",
		"GinBranch",
		"GinBrowse",
		"GinCd",
		"GinLcd",
		"GinTcd",
		"GinChaperon",
		"GinDiff",
		"GinEdit",
		"GinLog",
		"GinPatch",
		"GinStatus",
	},
	keys = {
		{ "<Leader>gP", "<cmd>Gin push<CR>", desc = "Push" },
		{ "<Leader>gp", "<cmd>Gin pull --autostash<CR>", desc = "Pull" },
		{ "<leader>gx", "<Cmd>GinBrowse ++repository<Cr>", desc = "Open the repository webpage" },
		{ "<leader>gbl", "<Cmd>GinBlame HEAD %<Cr>", desc = "Blame" },
		{ "<leader>gD", "<Cmd>GinDiff<Cr>", desc = "Gin diff" },
		{ "<leader>gl", "<Cmd>GinLog ++opener=tabedit --oneline<Cr>", desc = "Log" },
		{
			"<leader>gc",
			git_commit_with_diff,
			desc = "Commit",
		},
		{ "<leader>gf", ":Gin fetch ", desc = "Fetch" },
		{ "<leader>gm", ":Gin merge ", desc = "Merge" },
		{ "<leader>g<C-r>", ":Gin rebase --autostash ", desc = "Rebase" },
		{ "<leader>gC", "<Cmd>GinCd<Cr>", desc = "Change cwd to git root dir" },
	},
	init = function()
		-- git での確認をスキップ
		vim.g["gin_proxy_apply_without_confirm"] = 1
		-- エディタの開き方
		vim.g["gin_proxy_editor_opener"] = "split"
		vim.g["gin_log_persistent_args"] = { "++emojify", "--graph" }
		vim.g["gin_blame_persistent_args"] = { "++emojify" }
		vim.g["gin_patch_default_args"] = { "++no-worktree" }
	end,
	config = function()
		require("denops-lazy").load("vim-gin", { wait_load = false })

		local gin_keymap_group = vim.api.nvim_create_augroup("GinKeymap", { clear = true })
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "gin", "gin-diff", "gin-log", "gin-status", "gin-branch", "gin-buffer" },
			group = gin_keymap_group,
			callback = function()
				local set = vim.keymap.set
				local opts = function(o)
					for k, v in pairs({ buffer = true, noremap = true }) do
						o[k] = v
					end
					return o
				end
				set({ "n" }, "c", git_commit_with_diff, opts({ desc = "Commit" }))
				set({ "n" }, "s", "<Cmd>GinStatus<Cr>", opts({ desc = "Status" }))
				set({ "n" }, "d", "<Cmd>GinDiff --staged<Cr>", opts({ desc = "Diff" }))
				set({ "n" }, "p", "<Cmd>Gin push<Cr>", opts({ desc = "Push" }))
				set({ "n" }, "P", "<Cmd>Gin pull<Cr>", opts({ desc = "Pull" }))
				set({ "n" }, "if", "<Plug>(gin-action-fixup:instant-fixup)", opts({ desc = "Fixup" }))
				set({ "n" }, "ir", "<Plug>(gin-action-fixup:instant-reword)", opts({ desc = "Reword" }))
				set({ "n" }, "q", "<Cmd>q<Cr>", opts({ desc = "Close" }))
				vim.opt_local.buflisted = false
			end,
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "gin-status",
			group = gin_keymap_group,
			callback = function()
				local set = vim.keymap.set
				local opts = function(o)
					for k, v in pairs({ buffer = true, noremap = true }) do
						o[k] = v
					end
					return o
				end
				set({ "n" }, "h", "<Plug>(gin-action-stage)", opts({ desc = "Stage" }))
				set({ "n" }, "l", "<Plug>(gin-action-unstage)", opts({ desc = "Unstage" }))
				set({ "n" }, "xx", "<Plug>(gin-action-patch)", opts({ desc = "Patch" }))
				set({ "n" }, "xc", "<Plug>(gin-action-chaperon)", opts({ desc = "Resolve confrict" }))
			end,
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "gin-diff",
			group = gin_keymap_group,
			callback = function()
				local set = vim.keymap.set
				local opts = function(o)
					for k, v in pairs({ buffer = true, noremap = true }) do
						o[k] = v
					end
					return o
				end
				set({ "n" }, "x", function()
					local width = vim.api.nvim_win_get_width(0)
					local margin = 6
					local fit_width = width - margin

					-- staged バッファかどうかを判定
					local diffIsStaged = string.find(vim.api.nvim_buf_get_name(0), ";staged", 1, true) ~= nil
					local diffIsCached = string.find(vim.api.nvim_buf_get_name(0), ";cached", 1, true) ~= nil
					local staged = (function()
						if diffIsStaged or diffIsCached then
							return " --staged"
						else
							return ""
						end
					end)()
					vim.cmd([[GinDiff]] .. fit_width .. staged)
				end, opts({ desc = "Split diff" }))
			end,
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "gin-log",
			group = gin_keymap_group,
			callback = function()
				local set = vim.keymap.set
				local opts = function(o)
					for k, v in pairs({ buffer = true, noremap = true }) do
						o[k] = v
					end
					return o
				end
				set({ "n" }, "ri", "<plug>(gin-action-rebase:i)", opts({ desc = "interactive rebase" }))
			end,
		})
	end,
}
