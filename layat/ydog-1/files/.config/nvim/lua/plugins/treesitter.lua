return {
	-- syntax highlightなどをいい感じにするプラグイン
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			"nvim-treesitter/nvim-treesitter-context",
		},
		event = { "BufReadPre", "BufNewFile" },
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").setup()

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("vim-treesitter-start", {}),
				callback = function()
					pcall(vim.treesitter.start)
				end,
			})

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("TreesitterAutoInstall", { clear = true }),
				callback = function(event)
					local ok_ts, ts = pcall(require, "nvim-treesitter")
					if not ok_ts then
						return
					end
					if type(ts.install) ~= "function" then
						return
					end

					local ft = vim.bo[event.buf].ft
					local lang = vim.treesitter.language.get_lang(ft)
					if not lang then
						return
					end

					local ok_parsers, parsers = pcall(require, "nvim-treesitter.parsers")
					if not ok_parsers then
						return
					end
					if type(parsers.get_parser_configs) ~= "function" then
						return
					end

					local configs = parsers.get_parser_configs()
					if not configs[lang] then
						return
					end

					ts.install({ lang }):await(function(err)
						if err then
							return
						end
						pcall(vim.treesitter.start, event.buf)
						vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
						vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
					end)
				end,
			})
			-- 折り畳みの設定
			local opt = vim.opt
			opt.foldmethod = "expr"
			opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
		end,
	},
	-- treesitter を利用した textobject を追加する
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("nvim-treesitter-textobjects").setup({
				lookahead = true,
				selection_modes = {
					["@parameter.outer"] = "v", -- charwise
					["@function.outer"] = "V", -- linewise
					["@class.outer"] = "<c-v>", -- blockwise
				},
				move = {
					set_jumps = true,
				},
			})

			-- 引数などの入れ替え
			vim.keymap.set("n", "<leader>cw", function()
				require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner")
			end, { desc = "Swap next parameter" })
			vim.keymap.set("n", "<leader>cW", function()
				require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.inner")
			end, { desc = "Swap previous parameter" })

			-- テキストオブジェクトごとの移動
			local move = require("nvim-treesitter-textobjects.move")
			vim.keymap.set({ "n", "x", "o" }, "]m", function()
				move.goto_next_start("@function.outer", "textobjects")
			end, { desc = "Next function start" })
			vim.keymap.set({ "n", "x", "o" }, "]]", function()
				move.goto_next_start("@class.outer", "textobjects")
			end, { desc = "Next class start" })
			-- You can also pass a list to group multiple queries.
			vim.keymap.set({ "n", "x", "o" }, "]o", function()
				move.goto_next_start({ "@loop.inner", "@loop.outer" }, "textobjects")
			end, { desc = "Next loop start" })
			-- You can also use captures from other query groups like `locals.scm` or `folds.scm`
			vim.keymap.set({ "n", "x", "o" }, "]s", function()
				move.goto_next_start("@local.scope", "locals")
			end, { desc = "Next scope start" })
			vim.keymap.set({ "n", "x", "o" }, "]z", function()
				move.goto_next_start("@fold", "folds")
			end, { desc = "Next fold start" })

			vim.keymap.set({ "n", "x", "o" }, "]M", function()
				move.goto_next_end("@function.outer", "textobjects")
			end, { desc = "Next function end" })
			vim.keymap.set({ "n", "x", "o" }, "][", function()
				move.goto_next_end("@class.outer", "textobjects")
			end, { desc = "Next class end" })

			vim.keymap.set({ "n", "x", "o" }, "[m", function()
				move.goto_previous_start("@function.outer", "textobjects")
			end, { desc = "Previous function start" })
			vim.keymap.set({ "n", "x", "o" }, "[[", function()
				move.goto_previous_start("@class.outer", "textobjects")
			end, { desc = "Previous class start" })

			vim.keymap.set({ "n", "x", "o" }, "[M", function()
				move.goto_previous_end("@function.outer", "textobjects")
			end, { desc = "Previous function end" })
			vim.keymap.set({ "n", "x", "o" }, "[]", function()
				move.goto_previous_end("@class.outer", "textobjects")
			end, { desc = "Previous class end" })
			vim.keymap.set({ "n", "x", "o" }, "]i", function()
				move.goto_next("@conditional.outer", "textobjects")
			end, { desc = "Next conditional" })
			vim.keymap.set({ "n", "x", "o" }, "[i", function()
				move.goto_previous("@conditional.outer", "textobjects")
			end, { desc = "Previous conditional" })
			vim.keymap.set(
				{ "n", "x", "o" },
				",",
				require("nvim-treesitter-textobjects.repeatable_move").repeat_last_move_next,
				{ desc = "Repeat last textobject move" }
			)
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("treesitter-context").setup({
				enable = true,
				multiwindow = false,
				max_lines = 0,
				min_window_height = 0,
				line_numbers = true,
				multiline_threshold = 20,
				trim_scope = "outer",
				mode = "cursor",
				separator = nil,
				zindex = 20,
				on_attach = nil,
			})
			vim.keymap.set("n", "[@", function()
				require("treesitter-context").go_to_context(vim.v.count1)
			end, { desc = "Go up to context", noremap = true, silent = true })
		end,
	},
}
