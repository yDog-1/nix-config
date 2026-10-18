---Keep pylsp's navigation/completion; Ruff owns Python formatting and linting.
---@type vim.lsp.Config
return {
	settings = {
		pylsp = {
			plugins = {
				autopep8 = { enabled = false },
				yapf = { enabled = false },
				flake8 = { enabled = false },
				mccabe = { enabled = false },
				pycodestyle = { enabled = false },
				pydocstyle = { enabled = false },
				pyflakes = { enabled = false },
				pylint = { enabled = false },
			},
		},
	},
}
