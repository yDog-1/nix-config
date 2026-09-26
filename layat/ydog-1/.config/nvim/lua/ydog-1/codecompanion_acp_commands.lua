local M = {}

local function get_chat(bufnr)
	if type(bufnr) ~= "number" or not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end

	local ok, chat = pcall(require("codecompanion").buf_get_chat, bufnr)
	if not ok or type(chat) ~= "table" or chat.adapter.type ~= "acp" then
		return
	end

	return chat
end

local function is_enabled(command, chat)
	if command.enabled == nil then
		return true
	end

	local ok, enabled
	if type(command.enabled) == "function" then
		ok, enabled = pcall(command.enabled, { adapter = chat.adapter })
	else
		ok, enabled = true, command.enabled
	end

	return ok and enabled == true
end

function M.items(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local chat = get_chat(bufnr)
	if not chat then
		return {}
	end

	local items = {}
	local config = require("codecompanion.config").interactions.chat.slash_commands
	for name, command in pairs(config) do
		if name ~= "opts" and command.description and is_enabled(command, chat) then
			local interactions = command.opts and command.opts.interactions
			if not interactions or vim.tbl_contains(interactions, "chat") then
				table.insert(items, {
					word = "/" .. name,
					display = string.format("/%s  %s", name, command.description),
					kind = "base",
					action = { type = "slash_command", name = name, bufnr = bufnr },
				})
			end
		end
	end

	if config.opts.acp and config.opts.acp.enabled then
		local acp_commands = require("codecompanion.interactions.chat.acp.commands").get_commands_for_buffer(bufnr)
		for _, command in ipairs(acp_commands) do
			local description = command.description or "ACP agent command"
			if command.input and command.input ~= vim.NIL and type(command.input) == "table" and command.input.hint then
				description = description .. " " .. command.input.hint
			end
			table.insert(items, {
				word = "\\" .. command.name,
				display = string.format("\\%s  %s", command.name, description),
				kind = "base",
				action = { type = "acp_command", name = command.name, bufnr = bufnr },
			})
		end
	end

	table.sort(items, function(a, b)
		return a.word < b.word
	end)
	return items
end

local function execute_slash_command(chat, name)
	local command = require("codecompanion.config").interactions.chat.slash_commands[name]
	if not command or not is_enabled(command, chat) then
		return vim.notify("CodeCompanion command is no longer available: " .. name, vim.log.levels.WARN)
	end

	return require("codecompanion.interactions.chat.slash_commands").run({
		label = "/" .. name,
		config = command,
	}, chat)
end

local function insert_acp_command(chat, name)
	local config = require("codecompanion.config").interactions.chat.slash_commands
	if not (config.opts.acp and config.opts.acp.enabled) then
		return vim.notify("ACP slash command completion is disabled", vim.log.levels.WARN)
	end

	local commands = require("codecompanion.interactions.chat.acp.commands").get_commands_for_buffer(chat.bufnr)
	local selected
	for _, command in ipairs(commands) do
		if command.name == name then
			selected = command
			break
		end
	end
	if not selected then
		return vim.notify("ACP command is no longer available: " .. name, vim.log.levels.WARN)
	end
	if chat.current_request then
		return vim.notify("Wait for the current CodeCompanion request to finish first", vim.log.levels.WARN)
	end

	chat.ui:open()
	local bufnr = chat.bufnr
	local line_count = vim.api.nvim_buf_line_count(bufnr)
	local row = line_count - 1
	local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
	local text = "\\" .. name
	if selected.input and selected.input ~= vim.NIL and type(selected.input) == "table" and selected.input.hint then
		text = text .. " "
	end
	if line ~= "" and not line:match("%s$") then
		text = " " .. text
	end

	local was_modifiable = vim.bo[bufnr].modifiable
	vim.bo[bufnr].modifiable = true
	vim.api.nvim_buf_set_text(bufnr, row, #line, row, #line, { text })
	vim.bo[bufnr].modifiable = was_modifiable

	local winid = vim.fn.bufwinid(bufnr)
	if winid ~= -1 then
		vim.api.nvim_set_current_win(winid)
		vim.api.nvim_win_set_cursor(winid, { row + 1, #line + #text })
	end
end

function M.do_action(args)
	local item = args.items and args.items[1]
	local action = item and item.action
	if not action then
		return 0
	end

	local chat = get_chat(action.bufnr)
	if not chat then
		vim.notify("The CodeCompanion chat is no longer available", vim.log.levels.WARN)
		return 0
	end

	if action.type == "slash_command" then
		execute_slash_command(chat, action.name)
	elseif action.type == "acp_command" then
		insert_acp_command(chat, action.name)
	end

	return 0
end

function M.open(bufnr)
	if not get_chat(bufnr) then
		return vim.notify("This CodeCompanion chat does not use an ACP adapter", vim.log.levels.WARN)
	end

	vim.fn["ddu#start"]({
		name = "codecompanion_acp_commands",
	})
end

function M.setup()
	vim.cmd([[
		function! YdogCodeCompanionACPCommandItems() abort
			return luaeval("YdogCodeCompanionACPCommands.items(vim.api.nvim_get_current_buf())")
		endfunction
	]])
	_G.YdogCodeCompanionACPCommands = M

	vim.fn["ddu#custom#action"]("source", "vim", "do", function(args)
		return M.do_action(args)
	end)

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "codecompanion",
		group = vim.api.nvim_create_augroup("ydog-1.codecompanion-acp-commands", { clear = true }),
		callback = function(args)
			vim.keymap.set("n", "<leader>aC", function()
				M.open(args.buf)
			end, { buffer = args.buf, desc = "CodeCompanion: ACP commands" })
		end,
	})

	vim.fn["ddu#custom#patch_local"]("codecompanion_acp_commands", {
		sources = {
			{
				name = "vim",
				params = { func = "YdogCodeCompanionACPCommandItems" },
				options = {
					defaultAction = "do",
				},
			},
		},
		kindOptions = {
			base = {
				defaultAction = "do",
			},
		},
		uiParams = {
			ff = {
				startAutoAction = false,
				ignoreEmpty = false,
			},
		},
	})
end

return M
