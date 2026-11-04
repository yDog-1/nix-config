local oil_width = 40

return {
	{
		"stevearc/oil.nvim",
		-- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
		lazy = false,
		keys = {
			{
				"<Leader>e",
				function()
					require("oil").open(nil, {
						preview = {
							vertical = true,
							split = "belowright",
						},
					}, function()
						vim.cmd("vertical resize" .. oil_width)
					end)
				end,
				desc = "Open parent directory",
			},
		},
		---@module 'oil'
		---@type oil.SetupOpts
		opts = {
			keymaps = {
				["~"] = { "<cmd>edit $HOME<CR>", desc = "Open home directory" },
				["g?"] = { "actions.show_help", mode = "n" },
				["gd"] = {
					function()
						if vim.g.oil_detailed_columns then
							vim.g.oil_detailed_columns = false
							require("oil").set_columns({ "icon" })
							vim.cmd("vertical resize" .. oil_width)
							return
						end
						vim.g.oil_detailed_columns = true
						require("oil").set_columns({ "icon", "permissions", "size", "mtime" })
						vim.cmd("horizontal wincmd =")
					end,
					desc = "Show file details",
				},
				["<CR>"] = "actions.select",
				["<C-s>"] = { "actions.select", opts = { vertical = true, close = true } },
				["H"] = { "actions.select", opts = { horizontal = true, close = true } },
				["<C-p>"] = "actions.preview",
				["<C-c>"] = { "actions.close", mode = "n" },
				["q"] = { "actions.close", mode = "n" },
				["L"] = "actions.refresh",
				["-"] = { "actions.parent", mode = "n" },
				["_"] = { "actions.open_cwd", mode = "n" },
				["`"] = { "actions.cd", mode = "n" },
				["gs"] = { "actions.change_sort", mode = "n" },
				["gx"] = "actions.open_external",
				["g."] = { "actions.toggle_hidden", mode = "n" },
				["g\\"] = { "actions.toggle_trash", mode = "n" },
			},
			use_default_keymaps = false,
			skip_confirm_for_simple_edits = true,
			view_options = {
				show_hidden = true,
			},
			float = {
				win_options = {
					winblend = 0,
				},
			},
		},
		config = function(_, opts)
			require("oil").setup(opts)

			-- Rename file after move
			vim.api.nvim_create_autocmd("User", {
				pattern = "OilActionsPost",
				callback = function(event)
					if event.data.actions.type == "move" then
						require("snacks").rename.on_rename_file(event.data.actions.src_url, event.data.actions.dest_url)
					end
				end,
			})
		end,
	},
}
