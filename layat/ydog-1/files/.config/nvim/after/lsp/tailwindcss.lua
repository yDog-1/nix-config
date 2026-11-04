---@type vim.lsp.Config
return {
	workspace_required = true,
	root_dir = function(bufnr, on_dir)
		local root = vim.fs.root(bufnr, function(name, path)
			local file = vim.fs.joinpath(path, name)
			if name:match("^tailwind%.config%.[cm]?[jt]s$") then
				return (vim.uv.fs_stat(file) or {}).type == "file"
			end
			if
				not vim.tbl_contains(
					{ "package.json", "deno.json", "deno.jsonc", "import_map.json", "import_map.jsonc" },
					name
				)
			then
				return false
			end

			local ok, lines = pcall(vim.fn.readfile, file)
			if ok then
				for _, line in ipairs(lines) do
					if line:lower():find("tailwindcss", 1, true) then
						return true
					end
				end
			end
			return false
		end)
		if root then
			on_dir(root)
		end
	end,
}
