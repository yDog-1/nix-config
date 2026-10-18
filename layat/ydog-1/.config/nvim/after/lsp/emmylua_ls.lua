local lazy_root = require("lazy.core.config").options.root

local library = vim.api.nvim_get_runtime_file("lua", true)
for name, type in vim.fs.dir(lazy_root) do
	if type == "directory" then
		library[#library + 1] = vim.fs.joinpath(lazy_root, name, "lua")
	end
end

---@type vim.lsp.Config
return {
	settings = {
		emmylua = {
			runtime = {
				version = "LuaJIT",
				requirePattern = { "?.lua", "?/init.lua", "lua/?.lua", "lua/?/init.lua" },
			},
			strict = {
				requirePath = true,
			},
			workspace = {
				library = library,
			},
		},
	},
}
