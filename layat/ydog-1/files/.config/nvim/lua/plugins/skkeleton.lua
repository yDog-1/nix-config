return {
	{
		"https://github.com/vim-skk/skkeleton",
		dependencies = {
			"vim-denops/denops.vim",
			"https://github.com/delphinus/skkeleton_indicator.nvim",
			"https://github.com/NI57721/skkeleton-henkan-highlight",
		},
		keys = {
			{ "<C-f>", "<Plug>(skkeleton-enable)", mode = { "i", "c", "t" } },
		},
		lazy = false,
		config = function()
			local skk_dict_path = os.getenv("SKK_DICT_PATH")
			local skk_dict_paths = os.getenv("SKK_DICT_PATHS")

			-- 文字列分割関数
			local function split_string(str, delimiter)
				local result = {}
				if str == nil or str == "" then
					return result
				end
				for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
					if match ~= "" then
						table.insert(result, match)
					end
				end
				return result
			end

			local skk_dicts = split_string(skk_dict_paths, ",")

			local skk_database_path = vim.fn.expand((os.getenv("XDG_STATE_HOME") or "~/.local/state") .. "/skk/deno_kv")

			-- skk_database_pathのディレクトリを自動作成
			local function ensure_directory(path)
				local dir = vim.fn.fnamemodify(path, ":h")
				if vim.fn.isdirectory(dir) == 0 then
					local success = vim.fn.mkdir(dir, "p")
					if success == 0 then
						vim.notify("Failed to create directory: " .. dir, vim.log.levels.ERROR)
						return false
					end
				end
				return true
			end

			if not ensure_directory(skk_database_path) then
				return
			end

			vim.fn["skkeleton#config"]({
				completionRankFile = skk_dict_path .. "/rank.json",
				globalDictionaries = skk_dicts,
				userDictionary = skk_dict_path .. "/SKK-JISYO.user",
				-- 候補選択メニューが出るまでの数
				showCandidatesCount = 2,
				-- Denoのインメモリキャッシュで高速化
				databasePath = skk_database_path,
				sources = { "deno_kv", "skk_dictionary" },
				-- キャンセルの挙動
				immediatelyCancel = false,
				-- 変換中の文字を無くす
				markerHenkan = "",
				markerHenkanSelect = "",
			})

			vim.fn["skkeleton#register_keymap"]("henkan", "<CR>", "kakutei")
			vim.fn["skkeleton#register_kanatable"]("rom", {
				jj = "escape",
			})

			-- Deno KVのデータベースを更新
			vim.fn["skkeleton#update_database"](skk_database_path)

			require("denops-lazy").load("skkeleton", { wait_load = false })
		end,
	},
	-- skkeletonの入力中、右下にインジケータを表示
	{
		"https://github.com/delphinus/skkeleton_indicator.nvim",
		branch = "v2",
		config = function()
			require("skkeleton_indicator").setup({
				zindex = 150,
			})
		end,
	},
	{
		"https://github.com/NI57721/skkeleton-henkan-highlight",
		config = function()
			vim.api.nvim_set_hl(0, "SkkeletonHenkan", {
				bg = "#85d3f2",
				fg = "#2c2e34",
				blend = 0,
			})
			vim.api.nvim_set_hl(0, "SkkeletonHenkanSelect", {
				link = "SkkeletonHenkan",
			})
		end,
	},
}
