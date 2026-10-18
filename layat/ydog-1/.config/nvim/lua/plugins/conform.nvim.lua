local web_formatter = {
	"prettier",
	"biome",
	stop_after_first = true,
}
return {
	{
		"https://github.com/stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<Leader>cf",
				function()
					require("conform").format({ async = true })
				end,
				mode = "",
				desc = "Format buffer",
			},
		},
		opts = {
			default_format_opts = {
				lsp_format = "fallback",
			},
			formatters_by_ft = {
				javascript = web_formatter,
				typescript = { "prettier" },
				javascriptreact = web_formatter,
				typescriptreact = { "prettier" },
				html = web_formatter,
				css = web_formatter,
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				lua = { "stylua" },
				gdscript = { "gdscript-formatter" },
				go = { "goimports" },
				nix = { "alejandra" },
			},
			format_on_save = {
				timeout_ms = 1000,
				lsp_format = "fallback",
			},
			formatters = {
				["gdscript-formatter"] = {
					-- Stdin mode discovers .editorconfig from its working directory.
					cwd = function(_, ctx)
						return ctx.dirname
					end,
				},
				prettier = { require_cwd = true },
				biome = { require_cwd = true },
			},
		},
	},
}
