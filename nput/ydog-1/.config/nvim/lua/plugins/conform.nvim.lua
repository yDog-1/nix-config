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
				typescript = web_formatter,
				javascriptreact = web_formatter,
				typescriptreact = web_formatter,
				html = web_formatter,
				css = web_formatter,
				lua = { "stylua" },
				go = { "goimports", "gofmt" },
				nix = { "alejandra" },
			},
			format_after_save = {
				lsp_format = "fallback",
			},
			formatters = {
				prettier = { require_cwd = true },
				biome = { require_cwd = true },
			},
		},
	},
}
