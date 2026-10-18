local M = {}

M.biome_configs = { "biome.json", "biome.jsonc", ".biome.json", ".biome.jsonc" }

local eslint_flat_configs = {
	"eslint.config.js",
	"eslint.config.mjs",
	"eslint.config.cjs",
	"eslint.config.ts",
	"eslint.config.mts",
	"eslint.config.cts",
}
local eslint_legacy_configs = {
	".eslintrc",
	".eslintrc.js",
	".eslintrc.cjs",
	".eslintrc.json",
	".eslintrc.yaml",
	".eslintrc.yml",
}

local function dirname(bufnr)
	return vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
end

local function ancestors(bufnr)
	local dir = dirname(bufnr)
	local dirs = { dir }
	for parent in vim.fs.parents(dir) do
		dirs[#dirs + 1] = parent
	end
	return dirs
end

---Find the nearest config, relative to the file rather than Neovim's cwd.
function M.config_root(bufnr, names)
	return vim.fs.root(bufnr, names)
end

function M.root(bufnr)
	return M.config_root(bufnr, { ".git" }) or dirname(bufnr)
end

---Return the nearest ESLint config root and whether it uses legacy config.
function M.eslint_root(bufnr)
	for _, dir in ipairs(ancestors(bufnr)) do
		for _, name in ipairs(eslint_flat_configs) do
			if vim.fn.filereadable(vim.fs.joinpath(dir, name)) == 1 then
				return dir, false
			end
		end
		for _, name in ipairs(eslint_legacy_configs) do
			if vim.fn.filereadable(vim.fs.joinpath(dir, name)) == 1 then
				return dir, true
			end
		end
		local ok, lines = pcall(vim.fn.readfile, vim.fs.joinpath(dir, "package.json"))
		if ok then
			local decoded, package = pcall(vim.json.decode, table.concat(lines, "\n"))
			if decoded and type(package) == "table" and type(package.eslintConfig) == "table" then
				return dir, true
			end
		end
	end
end

---Prefer the nearest project executable, including workspace ancestors.
function M.node_command(bufnr, name)
	for _, dir in ipairs(ancestors(bufnr)) do
		local command = vim.fs.joinpath(dir, "node_modules", ".bin", name)
		if vim.fn.executable(command) == 1 then
			return command
		end
	end
	return name
end

return M
