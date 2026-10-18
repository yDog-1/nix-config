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
				["*"] = { "prettier", "biome" },
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
				prettier = {
					require_cwd = true,
					-- Unknown stdin input produces no output; keep the temporary file unchanged instead.
					stdin = false,
					args = { "--write", "--ignore-unknown", "$FILENAME" },
					range_args = function(_, ctx)
						local start_offset, end_offset =
							require("conform.util").get_offsets_from_range(ctx.buf, ctx.range)
						return {
							"--write",
							"--ignore-unknown",
							"$FILENAME",
							"--range-start=" .. start_offset,
							"--range-end=" .. end_offset,
						}
					end,
				},
				biome = {
					require_cwd = true,
					-- File mode also skips known languages whose formatter is disabled.
					stdin = false,
					args = function(self, ctx)
						local args = require("conform.formatters.biome").args(self, ctx)
						args[2] = "--write"
						return args
					end,
					append_args = { "--files-ignore-unknown=true", "--no-errors-on-unmatched" },
				},
			},
		},
	},
}
