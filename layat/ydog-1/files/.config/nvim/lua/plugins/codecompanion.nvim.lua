local function update_winbar(event)
	local bufnr = event.data and event.data.bufnr
	---@diagnostic disable-next-line: undefined-field
	local metadata = bufnr and _G.codecompanion_chat_metadata and _G.codecompanion_chat_metadata[bufnr]
	local adapter = metadata and metadata.adapter
	if not adapter or not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end

	local parts = { adapter.name, adapter.model or "default" }
	local mode = metadata.config_options and metadata.config_options.mode
	if mode and (mode.current or mode.name) then
		local name = mode.current or mode.name
		local highlights = {
			plan = "CodeCompanionModePlan",
			build = "CodeCompanionModeBuild",
		}
		local highlight = highlights[name:lower()]
		table.insert(parts, highlight and string.format("%%#%s#%s%%*", highlight, name) or name)
	end

	vim.b[bufnr].codecompanion_winbar = " " .. table.concat(parts, " | ") .. " "
	vim.cmd.redrawstatus()
end

local function cycle_session_mode(chat, direction)
	local connection = chat.acp_connection
	if chat.adapter.type ~= "acp" or not connection then
		return
	end

	for _, option in ipairs(connection:get_config_options()) do
		if option.category == "mode" and option.type == "select" then
			local values = require("codecompanion.acp").flatten_config_options(option.options or {})
			if #values < 2 then
				return
			end

			for i, value in ipairs(values) do
				if value.value == option.currentValue then
					local next_value = values[(i - 1 + direction) % #values + 1]
					if connection:set_config_option(option.id, next_value.value) then
						chat:update_metadata()
					end
					return
				end
			end
			return
		end
	end
end

return {
	"https://github.com/olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	init = function()
		local function set_highlights()
			vim.api.nvim_set_hl(0, "CodeCompanionModePlan", { link = "DiagnosticWarn" })
			vim.api.nvim_set_hl(0, "CodeCompanionModeBuild", { link = "DiagnosticInfo" })
		end

		set_highlights()
		vim.api.nvim_create_autocmd("ColorScheme", { callback = set_highlights })
		vim.api.nvim_create_autocmd("User", {
			pattern = {
				"CodeCompanionChatCreated",
				"CodeCompanionChatAdapter",
				"CodeCompanionChatModel",
				"CodeCompanionChatACPConfigChanged",
			},
			callback = update_winbar,
		})
	end,
	keys = {
		{
			"<m-l>",
			":CodeCompanion #{buffer} ",
			mode = { "n" },
			desc = "CodeCompanion: inline",
		},
		{
			"<m-l>",
			":'<,'>CodeCompanion ",
			mode = { "x" },
			desc = "CodeCompanion: inline",
		},
		{
			"<leader>ao",
			"<cmd>CodeCompanionChat<CR>",
			mode = { "n", "x" },
			desc = "CodeCompanion: chat",
		},
		{
			"<leader>aa",
			"<cmd>CodeCompanionActions<CR>",
			mode = { "n", "x" },
			desc = "CodeCompanion: actions",
		},
	},
	opts = {
		adapters = {
			acp = {
				opencode = function()
					return require("codecompanion.adapters").extend("opencode", {
						defaults = {
							model = "openai/gpt-6-luna",
						},
					})
				end,
			},
		},
		interactions = {
			chat = {
				adapter = {
					name = "opencode",
				},
				keymaps = {
					next_session_mode = {
						callback = function(chat)
							cycle_session_mode(chat, 1)
						end,
						description = "Next ACP session mode",
						modes = { n = "<Tab>", i = "<Tab>" },
					},
					previous_session_mode = {
						callback = function(chat)
							cycle_session_mode(chat, -1)
						end,
						description = "Previous ACP session mode",
						modes = { n = "<S-Tab>", i = "<S-Tab>" },
					},
				},
			},
			inline = {
				adapter = {
					name = "openrouter",
					model = "deepseek/deepseek-v4.1-flash",
				},
			},
		},
		display = {
			chat = {
				window = {
					opts = {
						winbar = "%{%get(b:, 'codecompanion_winbar', '')%}",
					},
				},
			},
		},
	},
}
