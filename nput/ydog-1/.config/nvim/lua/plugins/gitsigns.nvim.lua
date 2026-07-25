return {
	"lewis6991/gitsigns.nvim",
	event = "BufRead",
	keys = function()
		local gitsigns = require("gitsigns")
		return {
			{
				"]c",
				function()
					if vim.wo.diff then
						vim.cmd.normal({ "]c", bang = true })
					else
						---@diagnostic disable-next-line: need-check-nil
						gitsigns.nav_hunk("next")
					end
				end,
				desc = "Next hunk",
			},
			{
				"[c",
				function()
					if vim.wo.diff then
						vim.cmd.normal({ "[c", bang = true })
					else
						---@diagnostic disable-next-line: need-check-nil
						gitsigns.nav_hunk("prev")
					end
				end,
				desc = "Previous hunk",
			},
			-- Actions
			{ "<leader>ga", gitsigns.stage_hunk, desc = "Stage hunk" },
			{ "<leader>gr", gitsigns.reset_hunk, desc = "Reset hunk" },
			{
				"<leader>ga",
				function()
					---@diagnostic disable-next-line: need-check-nil
					gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end,
				mode = "v",
				desc = "Stage hunk",
			},
			{
				"<leader>gr",
				function()
					---@diagnostic disable-next-line: need-check-nil
					gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end,
				mode = "v",
				desc = "Reset hunk",
			},
			{ "<leader>gA", gitsigns.stage_buffer, desc = "Stage buffer" },
			{ "<leader>gR", gitsigns.reset_buffer, desc = "Reset buffer" },
			{ "<leader>gh", gitsigns.preview_hunk, desc = "Preview hunk" },
			{ "<leader>gi", gitsigns.preview_hunk_inline, desc = "Preview hunk inline" },
			{
				"<leader>gbL",
				function()
					---@diagnostic disable-next-line: need-check-nil
					gitsigns.blame_line({ full = true })
				end,
				desc = "Blame on the current line",
			},
			{ "<leader>gq", gitsigns.setqflist, desc = "Open hunks list" },
			{
				"<leader>gQ",
				function()
					---@diagnostic disable-next-line: need-check-nil
					gitsigns.setqflist("all")
				end,
				desc = "Open all hunks list",
			},
			-- Text object
			{ "ih", gitsigns.select_hunk, mode = { "o", "x" }, desc = "inner hunk" },
			{ "<leader>gd", "<Cmd>Gitsigns diffthis<Cr>", desc = "Diff" },
		}
	end,
	opts = {
		current_line_blame = true,
		current_line_blame_opts = {
			delay = 200,
		},
	},
}
