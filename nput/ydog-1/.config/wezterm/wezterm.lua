local wezterm = require("wezterm")
local config = wezterm.config_builder()
local keybinds = require("keybinds")

-- OS検出関数
local function get_os()
	local target = wezterm.target_triple
	if target:find("windows") then
		return "windows"
	elseif target:find("darwin") then
		return "macos"
	else
		return "linux"
	end
end

local os_type = get_os()

-- 設定のホットリロード
config.automatically_reload_config = true

-- NeovimでSKKが有効なため、IMEを無効化
config.use_ime = false
-- 何故かWaylandでIMEが有効になってしまうため、Waylandも無効化
config.enable_wayland = false

-- キーバインドを設定
config.keys = keybinds.keys
config.key_tables = keybinds.key_tables
config.leader = keybinds.leader

-- マウス操作の挙動設定
config.mouse_bindings = {
	-- 右クリックでクリップボードから貼り付け
	{
		event = { Down = { streak = 1, button = "Right" } },
		mods = "NONE",
		action = wezterm.action.PasteFrom("Clipboard"),
	},
}

-- フォント設定
config.font = wezterm.font_with_fallback({
	{
		family = "Moralerspace Argon HW",
	},
})
config.font_size = 13

-- OS別の設定
if os_type == "windows" then
	-- Windows（WSL含む）の設定
	config.launch_menu = {
		{
			label = "WSL:Ubuntu",
			domain = { DomainName = "WSL:Ubuntu" },
		},
		{
			label = "PowerShell",
			args = { "pwsh", "-nol", "-wd", "~" },
			domain = { DomainName = "local" },
		},
		{
			label = "Command Prompt",
			args = { "cmd" },
			domain = { DomainName = "local" },
		},
	}

	config.wsl_domains = {
		{
			name = "WSL:Ubuntu",
			distribution = "Ubuntu",
			default_cwd = "~",
			default_prog = { "zsh" },
		},
	}

	-- WSLをデフォルトにする（WSLが利用可能な場合）
	config.default_domain = "WSL:Ubuntu"
	config.default_prog = { "pwsh", "-nol", "-wd", "~" }
elseif os_type == "linux" then
	-- Linux環境の設定
	config.launch_menu = {
		{
			label = "Bash",
			args = { "bash", "-l" },
		},
		{
			label = "Zsh",
			args = { "zsh", "-l" },
		},
		{
			label = "Fish",
			args = { "fish", "-l" },
		},
	}

	-- Linuxではローカルドメインのみ使用
	config.default_domain = "local"

	-- ユーザーのデフォルトシェルを使用
	local user_shell = os.getenv("SHELL") or "/bin/bash"
	config.default_prog = { user_shell, "-l" }
elseif os_type == "macos" then
	-- macOS環境の設定
	config.launch_menu = {
		{
			label = "Zsh",
			args = { "zsh", "-l" },
		},
		{
			label = "Bash",
			args = { "bash", "-l" },
		},
		{
			label = "Fish",
			args = { "fish", "-l" },
		},
	}

	config.default_domain = "local"

	-- macOSのデフォルトシェル（通常はzsh）
	local user_shell = os.getenv("SHELL") or "/bin/zsh"
	config.default_prog = { user_shell, "-l" }
end

config.window_background_opacity = 0.80
config.kde_window_background_blur = true
config.macos_window_background_blur = 20

-- ウィンドウを閉じる確認をしない
config.window_close_confirmation = "NeverPrompt"

-- タブの見た目
config.enable_tab_bar = false
config.window_decorations = "RESIZE"
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

config.status_update_interval = 500

-- <C-CR>などを有効化する
config.enable_kitty_keyboard = true

return config
