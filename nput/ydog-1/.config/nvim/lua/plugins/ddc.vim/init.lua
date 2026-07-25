local augroup = vim.api.nvim_create_augroup("ydog.ddc_vim", { clear = true })

---@diagnostic disable-next-line: unused
local cmdline_pre = function(mode)
	local buf = vim.api.nvim_get_current_buf()
	local buf_config = vim.fn["ddc#custom#get_buffer"]()
	vim.api.nvim_create_autocmd("User", {
		group = augroup,
		pattern = "DDCCmdlineLeave",
		once = true,
		callback = function()
			if vim.api.nvim_buf_is_valid(buf) then
				vim.api.nvim_buf_call(buf, function()
					vim.fn["ddc#custom#set_buffer"](buf_config or vim.empty_dict())
				end)
			end
		end,
	})

	vim.fn["ddc#enable_cmdline_completion"]()
end

for _, lhs in ipairs({ "/", "?", ":" }) do
	vim.keymap.set({ "n", "x" }, lhs, function()
		cmdline_pre(lhs)
		return lhs
	end, { expr = true, noremap = true })
end

return {
	{
		"https://github.com/Shougo/ddc.vim",
		lazy = false,
		dependencies = {
			"vim-denops/denops.vim",
		},
		config = function()
			vim.fn["ddc#custom#load_config"](
				vim.fs.joinpath(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)), "init.ts")
			)
			vim.fn["ddc#enable"]({ "treesitter" })
		end,
	},
	{
		"https://github.com/Shougo/pum.vim",
		dependencies = { "cohama/lexima.vim" },
		config = function()
			vim.fn["pum#set_option"]({
				border = "single",
				max_height = 15,
				max_width = 80,
				scrollbar_char = "",
			})

			vim.fn["lexima#set_default_rules"]()
			vim.keymap.set({ "i", "c" }, "<C-n>", function()
				if vim.fn["pum#visible"]() then
					return "<cmd>call pum#map#insert_relative(+1, 'loop')<CR>"
				else
					return "<cmd>call ddc#map#manual_complete()<CR>"
				end
			end, { expr = true })
			vim.keymap.set({ "i", "c" }, "<C-p>", "<cmd>call pum#map#insert_relative(-1, 'loop')<CR>")
			vim.keymap.set({ "i", "c" }, "<C-y>", "<cmd>call pum#map#confirm()<CR>")
			vim.keymap.set("i", "<CR>", function()
				if vim.fn["pum#visible"]() and vim.fn["pum#entered"]() then
					return "<cmd>call pum#map#confirm()<CR>"
				else
					return "<C-r>=lexima#expand('<LT>CR>', 'i')<CR>"
				end
			end, { expr = true })
			vim.keymap.set("c", "<CR>", function()
				if vim.fn["pum#visible"]() and vim.fn["pum#entered"]() then
					return "<cmd>call pum#map#confirm()<CR>"
				else
					return "<CR>"
				end
			end, { expr = true })
			vim.keymap.set({ "i", "c" }, "<C-e>", "<cmd>call pum#map#cancel()<CR>")
			vim.keymap.set({ "i", "c" }, "<tab>", function()
				if vim.fn["pum#visible"]() then
					if vim.fn["pum#entered"]() then
						return "<cmd>call pum#map#confirm()<CR>"
					end
					return '<cmd>call pum#map#insert_relative(1, "loop")<CR><cmd>call pum#map#confirm()<CR>'
				end
				if vim.fn["denippet#jumpable"]() then
					return "<plug>(denippet-jump-next)"
				end
				return "<tab>"
			end, { expr = true })
			vim.keymap.set({ "i", "c" }, "<S-tab>", function()
				if vim.fn["denippet#jumpable"](-1) then
					return "<plug>(denippet-jump-prev)"
				end
				return "<S-tab>"
			end, { expr = true })
			vim.keymap.set({ "i", "c" }, "<C-x>f", "<cmd>call ddc#map#manual_complete({'sources':['file']})<CR>")
			vim.keymap.set({ "i", "c" }, "<C-x><C-f>", "<cmd>call ddc#map#manual_complete({'sources':['file']})<CR>")
			vim.keymap.set("i", "<C-u>", function()
				local ok, _ = pcall(vim.fn["popup_preview#is_enabled"])
				if ok then
					if vim.fn["pum#visible"]() and vim.fn["popup_preview#is_enabled"]() then
						return "<cmd>call popup_preview#scroll(-4)<CR>"
					end
				end
				return "<C-u>"
			end, { expr = true })
			vim.keymap.set("i", "<C-d>", function()
				local ok, _ = pcall(vim.fn["popup_preview#is_enabled"])
				if ok then
					if vim.fn["pum#visible"]() and vim.fn["popup_preview#is_enabled"]() then
						return "<cmd>call popup_preview#scroll(+4)<CR>"
					end
				end
				return "<C-d>"
			end, { expr = true })
		end,
	},
	{
		"https://github.com/uga-rosa/denippet.vim",
		lazy = false,
		dependencies = {
			"vim-denops/denops.vim",
			"https://github.com/rafamadriz/friendly-snippets",
		},
		config = function()
			-- Load snippets from friendly-snippets/snippets
			local options = require("lazy.core.config").options
			local root = vim.fs.joinpath(options.root, "friendly-snippets", "snippets")
			for name, type in vim.fs.dir(root) do
				if type == "file" then
					vim.fn["denippet#load"](vim.fs.joinpath(root, name))
				elseif type == "directory" then
					local dirname = name
					for name2, type2 in vim.fs.dir(vim.fs.joinpath(root, dirname)) do
						if type2 == "file" then
							vim.fn["denippet#load"](vim.fs.joinpath(root, dirname, name2))
						end
					end
				end
			end
		end,
	},
	"https://github.com/Shougo/ddc-ui-pum",
	"https://github.com/Shougo/ddc-source-lsp",
	"https://github.com/Shougo/ddc-source-around",
	"https://github.com/matsui54/ddc-source-buffer",
	"https://github.com/LumaKernel/ddc-source-file",
	"https://github.com/Shougo/ddc-source-cmdline",
	"https://github.com/Shougo/ddc-source-cmdline_history",
	"https://github.com/Shougo/ddc-source-input",
	"https://github.com/Shougo/ddc-source-shell_native",
	"https://github.com/tani/ddc-fuzzy",
	"https://github.com/Shougo/ddc-filter-sorter_lsp_kind",
	"https://github.com/Shougo/ddc-filter-sorter_rank",
	"https://github.com/Shougo/ddc-filter-converter_kind_labels",
	"https://github.com/Shougo/ddc-filter-matcher_length",
	"https://github.com/Shougo/ddc-filter-matcher_prefix",
	"https://github.com/yDog-1/ddc-filter-converter_strip_completion_text_chars",
	-- post filter
	"https://github.com/Shougo/ddc-filter-sorter_head",
	"https://github.com/matsui54/ddc-postfilter_score",
	{
		"https://github.com/matsui54/denops-popup-preview.vim",
		init = function()
			vim.g.popup_preview_config = {
				max_height = 30,
				max_width = 60,
			}
		end,
		config = function()
			vim.fn["popup_preview#enable"]()
		end,
	},
	{
		"https://github.com/matsui54/denops-signature_help",
		init = function()
			vim.g.signature_help_config = {
				border = false,
				contentsStyle = "labels",
			}
		end,
		config = function()
			vim.fn["signature_help#enable"]()
		end,
	},
}
