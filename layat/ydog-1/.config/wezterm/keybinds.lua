local wezterm = require("wezterm")
local io = require("io")
local os = require("os")
local act = wezterm.action

return {
	-- Ctrl-Spaceをリーダーキーに設定
	leader = {
		key = "Space",
		mods = "CTRL",
		timeout_milliseconds = 2000,
	},

	keys = {
		-- コマンドパレットを開く
		{ mods = "LEADER", key = "p", action = act.ActivateCommandPalette },
		-- 新しいタブを開く
		{ mods = "LEADER", key = "o", action = act.ShowLauncher },
		-- ランチャーメニューを開く
		{ mods = "LEADER", key = "n", action = act.SpawnTab("CurrentPaneDomain") },
		-- ペイン操作
		{ mods = "LEADER", key = "s", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{ mods = "LEADER", key = "v", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		-- ペインを移動
		{ mods = "LEADER", key = "l", action = act.ActivatePaneDirection("Right") },
		{ mods = "LEADER", key = "h", action = act.ActivatePaneDirection("Left") },
		{ mods = "LEADER", key = "j", action = act.ActivatePaneDirection("Down") },
		{ mods = "LEADER", key = "k", action = act.ActivatePaneDirection("Up") },
		-- タブを移動
		{ mods = "LEADER|CTRL", key = "l", action = act.ActivateTabRelative(1) },
		{ mods = "LEADER|CTRL", key = "h", action = act.ActivateTabRelative(-1) },
		-- ペインを閉じる
		{ mods = "LEADER", key = "c", action = act.CloseCurrentPane({ confirm = false }) },
		-- タブを閉じる
		{ mods = "LEADER|CTRL", key = "c", action = act.CloseCurrentTab({ confirm = false }) },
		-- 現在のターミナルのスクロールバック全体を同じウィンドウ内のNeovimで開く
		{
			mods = "CTRL|SHIFT",
			key = "E",
			action = wezterm.action_callback(function(window, pane)
				local text = pane:get_lines_as_text(pane:get_dimensions().scrollback_rows)
				local name = os.tmpname()

				local file = io.open(name, "w+")
				if file == nil then
					return
				end

				file:write(text)
				file:flush()
				file:close()

				window:perform_action(
					act.SpawnCommandInNewTab({
						args = { "zsh", "-lc", "exec $EDITOR " .. name },
					}),
					pane
				)

				wezterm.sleep_ms(1000)
				os.remove(name)
			end),
		},
		-- スクロールモードに移行
		{
			mods = "LEADER",
			key = "@",
			action = act.ActivateKeyTable({
				name = "SCROLL",
				one_shot = false,
			}),
		},
	},

	key_tables = {
		-- スクロールモードで
		SCROLL = {
			{ key = "u", action = act.ScrollByPage(-0.5) },
			{ key = "d", action = act.ScrollByPage(0.5) },
			{ key = "k", action = act.ScrollByLine(-1) },
			{ key = "j", action = act.ScrollByLine(1) },
			{ key = "t", action = act.ScrollToTop },
			{ key = "b", action = act.ScrollToBottom },
			--
			{ key = "Escape", action = "PopKeyTable" },
			{ key = "@", action = "PopKeyTable" },
		},
	},
}
