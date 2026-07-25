vim.filetype.add({
	extension = {
		astro = "astro",
	},
	pattern = {
		["${HOME}/.local/share/chezmoi/.*"] = {
			function(path, buf)
				if path:match("/dot_") then
					return vim.filetype.match({
						filename = path:gsub("/dot_", "/."),
						buf = buf,
					})
				end
			end,
			-- テーブルの第二要素でpriorityを最低にしておくと、フォールバック相当になる
			{ priority = -math.huge },
		},
		-- ${HOME}/.local/share/chezmoi/dot_config/yamllint/config を yamlとして扱う
		["${HOME}/.local/share/chezmoi/dot_config/yamllint/config"] = "yaml",
	},
})
