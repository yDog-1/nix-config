local project = require("ydog-1.project")

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
				markdown = { "prettier" },
				lua = { "stylua" },
				python = { "ruff_format" },
				gdscript = { "gdscript_formatter" },
				go = { "goimports" },
				nix = { "alejandra" },
			},
			format_on_save = {
				timeout_ms = 1000,
				lsp_format = "fallback",
			},
			formatters = {
				gdscript_formatter = {
					inherit = false,
					command = "gdscript-formatter",
					args = {},
					stdin = true,
					-- Stdin mode discovers .editorconfig from its working directory.
					cwd = function(_, ctx)
						return ctx.dirname
					end,
				},
				prettier = {
					require_cwd = true,
					command = function(_, ctx)
						return project.node_command(ctx.buf, "prettier")
					end,
				},
				biome = {
					require_cwd = true,
					command = function(_, ctx)
						return project.node_command(ctx.buf, "biome")
					end,
				},
			},
		},
	},
}
