return {
	{
		"https://github.com/milanglacier/minuet-ai.nvim",
		event = { "BufReadPre", "BufNewFile" },
		keys = {
			{
				"<tab>",
				function()
					local duet = require("minuet.duet").action
					if duet.is_visible() then
						vim.schedule(function()
							vim.b.minuet_duet_denied_until_insert = true
							vim.b.minuet_duet_auto_epoch = (vim.b.minuet_duet_auto_epoch or 0) + 1
							duet.apply()
						end)
						return ""
					end
					return "<Tab>"
				end,
				expr = true,
				desc = "Apply Minuet Next Edit Suggestion",
			},
		},
		config = function()
			local function is_normal_buffer(bufnr)
				local buffer = bufnr or vim.api.nvim_get_current_buf()

				if vim.bo[buffer].buftype ~= "" then
					return false
				end

				if vim.api.nvim_buf_get_name(buffer) == "" then
					return false
				end

				if not vim.bo[buffer].modifiable then
					return false
				end

				if vim.bo[buffer].readonly then
					return false
				end

				return true
			end

			local function is_duet_enabled()
				-- 自動 duet は通常の編集可能なファイルだけで有効にする。
				return is_normal_buffer() and not string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), "%.env")
			end

			local function bump_auto_epoch(bufnr)
				-- 古いバッファ状態で予約された自動 duet 予測を無効化する。
				vim.b[bufnr].minuet_duet_auto_epoch = (vim.b[bufnr].minuet_duet_auto_epoch or 0) + 1
				return vim.b[bufnr].minuet_duet_auto_epoch
			end

			local function stop_duet_requests()
				-- deny 済みの候補が後から表示されないよう、実行中の duet job を止める。
				local ok, common = pcall(require, "minuet.duet.backends.common")
				if ok then
					common.terminate_all_jobs()
				end
			end

			local function setup_duet_autocmds()
				local group = vim.api.nvim_create_augroup("ydog.minuet_duet", { clear = true })
				local ns = vim.api.nvim_create_namespace("ydog.minuet_duet")
				local duet = require("minuet.duet").action

				local function deny_auto_predict(bufnr)
					-- deny 後は次の insert session まで duet preview を表示しない。
					vim.b[bufnr].minuet_duet_denied_until_insert = true
					bump_auto_epoch(bufnr)
					stop_duet_requests()
					duet.dismiss()
				end

				vim.api.nvim_create_autocmd("InsertLeave", {
					group = group,
					callback = function(args)
						-- 自動 duet request は InsertLeave からだけ発火させる。
						if vim.b[args.buf].minuet_duet_denied_until_insert then
							return
						end

						local bufnr = args.buf
						local changedtick = vim.b[bufnr].changedtick
						local auto_epoch = vim.b[bufnr].minuet_duet_auto_epoch

						vim.defer_fn(function()
							if
								vim.api.nvim_buf_is_valid(bufnr)
								and bufnr == vim.api.nvim_get_current_buf()
								and vim.b[bufnr].changedtick == changedtick
								and vim.b[bufnr].minuet_duet_auto_epoch == auto_epoch
								and not vim.b[bufnr].minuet_duet_denied_until_insert
								and is_duet_enabled()
								and vim.fn.mode() == "n"
							then
								duet.predict()
							end
						end, require("minuet").config.debounce)
					end,
				})

				vim.api.nvim_create_autocmd({ "InsertEnter", "TextChanged" }, {
					group = group,
					callback = function(args)
						-- InsertEnter は次の予測を許可し、TextChanged は古い予約だけを無効化する。
						if args.event == "InsertEnter" then
							vim.b[args.buf].minuet_duet_denied_until_insert = false
						end

						bump_auto_epoch(args.buf)
						duet.dismiss()
					end,
				})

				local esc = vim.keycode("<Esc>")
				vim.on_key(function(_, typed)
					if typed == esc and vim.fn.mode() == "n" then
						deny_auto_predict(vim.api.nvim_get_current_buf())
					end
				end, ns)
			end

			require("minuet").setup({
				virtualtext = {
					auto_trigger_ft = { "*" },
					auto_trigger_ignore_ft = {},
					keymap = {
						accept = "<M-C-l>",
						accept_line = "<M-l>",
						next = "<M-]>",
						prev = "<M-[>",
						dismiss = "<M-e>",
					},
				},
				duet = {
					provider = "openai_compatible",
					provider_options = {
						openai_compatible = {
							api_key = "OPENROUTER_API_KEY",
							end_point = "https://openrouter.ai/api/v1/chat/completions",
							model = "deepseek/deepseek-v4-flash",
							name = "OpenRouter",
							optional = {
								reasoning_effort = "none",
								provider = {
									sort = "throughput",
								},
							},
						},
					},
				},
				provider = "openai_compatible",
				request_timeout = 2.5,
				throttle = 1500,
				debounce = 600,
				provider_options = {
					openai_compatible = {
						api_key = "OPENROUTER_API_KEY",
						end_point = "https://openrouter.ai/api/v1/chat/completions",
						model = "deepseek/deepseek-v4-flash",
						name = "OpenRouter",
						optional = {
							max_tokens = 56,
							top_p = 0.9,
							provider = {
								sort = "throughput",
							},
							reasoning_effort = "none",
						},
					},
				},
				enable_predicates = { is_duet_enabled },
			})

			setup_duet_autocmds()
		end,
	},
}
