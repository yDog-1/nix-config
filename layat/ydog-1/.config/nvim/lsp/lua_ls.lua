local lazy_root = require("lazy.core.config").options.root

local library = vim.api.nvim_get_runtime_file("lua", true)
for name, type in vim.fs.dir(lazy_root) do
	if type == "directory" then
		library[#library + 1] = vim.fs.joinpath(lazy_root, name, "lua")
	end
end
vim.list_extend(library, {
	"${3rd}/luv/library",
	"${3rd}/busted/library",
	"${3rd}/luassert/library",
})

---@type vim.lsp.Config
return {
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
				pathStrict = true,
				path = { "?.lua", "?/init.lua" },
			},
			workspace = {
				library = library,
				checkThirdParty = "Disable",
			},
		},
	},
}
