for _, spec in ipairs({
	{ "Aibo", "<Leader>a", "󰧑 ", "red" },
}) do
	require("plugins.which-key.spec").add({
		mode = { "n", "v" },
		{ spec[2], group = spec[1], icon = { icon = spec[3], color = spec[4] } },
	})
end

vim.g.ai_agent = "opencode"

return {
	"lambdalisue/nvim-aibo",
	lazy = false,
	dependencies = {
		"https://github.com/Shougo/ddc.vim",
	},
	keys = {
		{
			"<leader>aa",
			string.format("<cmd>Aibo -opener=botright\\ vsplit -focus %s<CR>", vim.g.ai_agent or "opencode"),
			desc = "Chat with OpenCode",
		},
		{
			"<leader>as",
			"<cmd>AiboSend -input<CR>",
			desc = "Send to Aibo",
			mode = "n",
		},
		{
			"<leader>as",
			":AiboSend -input",
			desc = "Send to Aibo",
			mode = "v",
		},
	},
	config = function()
		require("aibo").setup({
			disable_startinsert_on_insert = false,
			disable_startinsert_on_startup = true,
			prompt_height = 20,
			prompt = {
				no_default_mappings = true,
				on_attach = function(bufnr)
					vim.o.hidden = true

					local opts = { buffer = bufnr, nowait = true, silent = true }
					local send_prompt_to_console = function()
						local prompt = require("aibo.internal.prompt_window")
						local console = require("aibo.internal.console_window")
						local history = require("aibo.internal.history")

						local info = prompt.get_info_by_bufnr(bufnr)
						if not info or not info.console_info then
							vim.notify(
								"Failed to find associated Aibo console",
								vim.log.levels.ERROR,
								{ title = "Aibo prompt" }
							)
							return
						end

						local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
						local content = table.concat(lines, "\n")
						if content == "" then
							return
						end

						history.add(content)
						history.clear_state(bufnr)

						if console.send(info.console_info.bufnr, content) then
							console.follow(info.console_info.bufnr)
							vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
							vim.bo[bufnr].modified = false
							vim.api.nvim_win_set_cursor(0, { 1, 0 })
						end
					end

					vim.keymap.set({ "n" }, "q", "<Cmd>q<CR>", opts)
					vim.keymap.set({ "n" }, "g<C-C>", "<Plug>(aibo-send)<C-C>", opts)
					vim.keymap.set({ "n" }, "<C-K>", "<Plug>(aibo-send)<Up>", opts)
					vim.keymap.set({ "n" }, "<C-J>", "<Plug>(aibo-send)<Down>", opts)
					vim.keymap.set({ "n" }, "<PageDown>", "<Plug>(aibo-send)<PageDown>", opts)
					vim.keymap.set({ "n" }, "<PageUp>", "<Plug>(aibo-send)<PageUp>", opts)
					vim.keymap.set({ "n" }, "<End>", "<Plug>(aibo-send)<End>", opts)
					vim.keymap.set({ "n" }, "<Home>", "<Plug>(aibo-send)<Home>", opts)
					vim.keymap.set({ "n" }, "<Up>", "<Plug>(aibo-send)<Up>", opts)
					vim.keymap.set({ "n" }, "<Down>", "<Plug>(aibo-send)<Down>", opts)
					vim.keymap.set({ "n" }, "<C-L>", "<Plug>(aibo-send)<C-L>", opts)
					vim.keymap.set({ "n" }, "<CR>", function()
						send_prompt_to_console()
						vim.cmd("q")
					end, opts)
					vim.keymap.set({ "n" }, "<F5>", "<Plug>(aibo-submit)<Cmd>q<CR>", opts)
					vim.keymap.set("n", "<C-CR>", "<Plug>(aibo-submit)<Cmd>q<CR>", opts)
					vim.keymap.set("i", "<C-CR>", "<Esc><Plug>(aibo-submit)<Cmd>q<CR>", opts)
					vim.keymap.set({ "n" }, "<C-G><C-O>", "<Plug>(aibo-send)", opts)

					-- for ddc.vim
					vim.fn["ddc#custom#patch_buffer"]("specialBufferCompletion", true)
				end,
			},
			console = {
				no_default_mappings = true,
				on_attach = function(bufnr)
					vim.o.hidden = true

					local opts = { buffer = bufnr, nowait = true, silent = true }

					---@param direction "up"|"down"
					local send_mouse_scroll = function(direction)
						local button = ({ up = 64, down = 65 })[direction]
						if not button then
							error(string.format("invalid scroll direction: %s", direction))
						end

						local mouse = vim.fn.getmousepos()
						local row = mouse.winrow
						local col = mouse.wincol

						if row <= 0 or col <= 0 then
							local cursor = vim.api.nvim_win_get_cursor(0)
							row = cursor[1]
							col = cursor[2] + 1
						end

						require("aibo.internal.console_window").send(
							bufnr,
							-- xterm SGR mouse: 64 = wheel up, 65 = wheel down.
							string.format("\27[<%d;%d;%dM", button, col, row)
						)
					end

					vim.keymap.set({ "n" }, "<C-K>", "<Plug>(aibo-send)<Up>", opts)
					vim.keymap.set({ "n" }, "<C-J>", "<Plug>(aibo-send)<Down>", opts)
					vim.keymap.set({ "n" }, "<PageDown>", "<Plug>(aibo-send)<PageDown>", opts)
					vim.keymap.set({ "n" }, "<PageUp>", "<Plug>(aibo-send)<PageUp>", opts)
					vim.keymap.set({ "n", "i" }, "<ScrollWheelDown>", function()
						send_mouse_scroll("down")
					end, opts)
					vim.keymap.set({ "n", "i" }, "<ScrollWheelUp>", function()
						send_mouse_scroll("up")
					end, opts)
					vim.keymap.set({ "n" }, "<C-U>", "<Plug>(aibo-send)<PageUp>", opts)
					vim.keymap.set({ "n" }, "<C-D>", "<Plug>(aibo-send)<PageDown>", opts)
					vim.keymap.set({ "n" }, "<End>", "<Plug>(aibo-send)<End>", opts)
					vim.keymap.set({ "n" }, "<Home>", "<Plug>(aibo-send)<Home>", opts)
					vim.keymap.set({ "n" }, "<Up>", "<Plug>(aibo-send)<Up>", opts)
					vim.keymap.set({ "n" }, "<Down>", "<Plug>(aibo-send)<Down>", opts)
					vim.keymap.set({ "n" }, "<Right>", "<Plug>(aibo-send)<Right>", opts)
					vim.keymap.set({ "n" }, "<Left>", "<Plug>(aibo-send)<Left>", opts)
					vim.keymap.set({ "n" }, "l", "<Plug>(aibo-send)<Right>", opts)
					vim.keymap.set({ "n" }, "h", "<Plug>(aibo-send)<Left>", opts)
					vim.keymap.set({ "n" }, "<C-P>", "<Plug>(aibo-send)<C-P>", opts)
					vim.keymap.set({ "n" }, "<C-N>", "<Plug>(aibo-send)<C-N>", opts)
					vim.keymap.set({ "n" }, "<C-L>", "<Plug>(aibo-send)<C-L>", opts)
					vim.keymap.set({ "n" }, "<C-C>", "<Plug>(aibo-send)<C-C>", opts)
					vim.keymap.set({ "n" }, "<Esc>", "<Plug>(aibo-send)<Esc>", opts)
					vim.keymap.set({ "n" }, "<BS>", "<Plug>(aibo-send)<BS>", opts)
					vim.keymap.set({ "n" }, "<Tab>", "<Plug>(aibo-send)<Tab>", opts)
					vim.keymap.set({ "n" }, "/", "<Plug>(aibo-send)/", opts)
					vim.keymap.set({ "n" }, "<C-G><C-O>", "<Plug>(aibo-send)", opts)
					vim.keymap.set({ "n" }, "<C-G>i", "<Plug>(aibo-direct)", opts)
					vim.keymap.set({ "n" }, "<C-G><C-i>", "<Plug>(aibo-direct)", opts)
					vim.keymap.set({ "n" }, "<CR>", "<Plug>(aibo-submit)", opts)
					vim.keymap.set({ "n" }, "<F5>", "<Plug>(aibo-submit)", opts)
					vim.keymap.set({ "n" }, "<C-CR>", "<Plug>(aibo-submit)", opts)
				end,
			},
		})
	end,
}
