{
  config,
  pkgs,
  ...
}: let
  catppuccin = import ../../../lib/style/catppucin-colors.nix;
  vdeTmuxConfig = with catppuccin.colors;
    builtins.replaceStrings
    [
      "@base@"
      "@sky@"
      "@mauve@"
      "@red@"
      "@sapphire@"
      "@subtext1@"
      "@surface0@"
      "@surface1@"
      "@text@"
      "@yellow@"
      "@peach@"
    ]
    [
      base
      sky
      mauve
      red
      sapphire
      subtext1
      surface0
      surface1
      text
      yellow
      peach
    ]
    (builtins.readFile ./vde-tmux.yml);
  seshCompletion = pkgs.runCommand "sesh-completion" {} ''
    mkdir -p $out/share/zsh/site-functions
    ${pkgs.sesh}/bin/sesh completion zsh > $out/share/zsh/site-functions/_sesh
  '';
  tmux-openrouter-credit = pkgs.writeShellScriptBin "tmux-openrouter-credit" ''
    print_usage() {
      printf '#[fg=#11111b,bg=#6c7086] %s #[default]' "$1"
    }

    cache_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/tmux-openrouter-credit"
    cache_file="$cache_dir/openrouter"
    now="$(${pkgs.coreutils}/bin/date +%s)"

    if [[ -s "$cache_file" ]]; then
      cache_mtime="$(${pkgs.coreutils}/bin/stat -c %Y "$cache_file")"
      if ((now - cache_mtime < 300)); then
        print_usage "$(${pkgs.coreutils}/bin/cat "$cache_file")"
        exit 0
      fi
    fi

    OPENROUTER_API_KEY="$(${pkgs.coreutils}/bin/cat ${config.sops.secrets.openrouter_api_key.path} 2>/dev/null || true)"
    export OPENROUTER_API_KEY
    usage="$(${pkgs.coreutils}/bin/timeout 8s ${pkgs.ai-usagebar}/bin/ai-usagebar --vendor openrouter --json --format 'OpenRouter {or_balance}' 2>/dev/null | ${pkgs.jq}/bin/jq -r '.text // empty' | ${pkgs.perl}/bin/perl -pe 's/<[^>]*>//g' || true)"

    if [[ "$usage" =~ [0-9] ]]; then
      ${pkgs.coreutils}/bin/mkdir -p "$cache_dir"
      printf '%s\n' "$usage" > "$cache_file.tmp"
      ${pkgs.coreutils}/bin/mv "$cache_file.tmp" "$cache_file"
      print_usage "$usage"
    elif [[ -s "$cache_file" ]]; then
      print_usage "$(${pkgs.coreutils}/bin/cat "$cache_file")"
    fi
  '';
  tmux-codex-usage = pkgs.writeShellScriptBin "tmux-codex-usage" ''
    print_usage() {
      printf '#[fg=#1f3d2b,bg=#a6e3a1] %s #[default]' "$1"
    }

    cache_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/tmux-codex-usage"
    cache_file="$cache_dir/codex"
    now="$(${pkgs.coreutils}/bin/date +%s)"

    if [[ -s "$cache_file" ]]; then
      cache_mtime="$(${pkgs.coreutils}/bin/stat -c %Y "$cache_file")"
      if ((now - cache_mtime < 300)); then
        print_usage "$(${pkgs.coreutils}/bin/cat "$cache_file")"
        exit 0
      fi
    fi

    usage="$(${pkgs.coreutils}/bin/timeout 8s ${pkgs.ai-usagebar}/bin/ai-usagebar --vendor openai --json --format 'Codex 5h {oai_session_pct}% W {oai_weekly_pct}%' 2>/dev/null | ${pkgs.jq}/bin/jq -r '.text // empty' | ${pkgs.perl}/bin/perl -pe 's/<[^>]*>//g' || true)"

    if [[ "$usage" =~ [0-9] ]]; then
      ${pkgs.coreutils}/bin/mkdir -p "$cache_dir"
      printf '%s\n' "$usage" > "$cache_file.tmp"
      ${pkgs.coreutils}/bin/mv "$cache_file.tmp" "$cache_file"
      print_usage "$usage"
    elif [[ -s "$cache_file" ]]; then
      print_usage "$(${pkgs.coreutils}/bin/cat "$cache_file")"
    fi
  '';
  tmux-sesh = pkgs.writeShellScriptBin "tmux-sesh" ''
    session="$(${pkgs.sesh}/bin/sesh list --hide-duplicates | ${pkgs.fzf}/bin/fzf \
      --height=100% \
      --no-sort \
      --layout=reverse \
      --border-label=' sesh ' \
      --prompt='session> ' \
      --preview='${pkgs.sesh}/bin/sesh preview {}' \
      --preview-window='right:55%')"

    if [[ -n "$session" ]]; then
      exec ${pkgs.sesh}/bin/sesh connect "$session"
    fi
  '';
in {
  home.packages = [
    pkgs.ai-usagebar
    pkgs.editprompt
    pkgs.sesh
    pkgs.vde-tmux
    seshCompletion
    tmux-codex-usage
    tmux-openrouter-credit
  ];

  sops.secrets.openrouter_api_key = {};

  xdg.configFile."vde/tmux/config.yml".text = vdeTmuxConfig;

  programs.tmux = {
    enable = true;

    plugins = [
      {
        plugin = pkgs.tmuxPlugins.catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor "mocha"
          set -g @catppuccin_window_status_style "basic"
          set -g @catppuccin_window_number_color "#{@thm_surface_0}"
          set -g @catppuccin_window_text_color "#{@thm_surface_0}"
          set -g @catppuccin_window_current_number_color "#{@thm_mauve}"
          set -g @catppuccin_window_text "#[fg=#{@thm_overlay_1}] #W"
          set -g @catppuccin_window_current_text " #W"
          set -g @catppuccin_directory_icon " "
          set -g @catppuccin_date_time_icon " "
          set -g @catppuccin_status_directory_text_fg "#{@thm_crust}"
          set -g @catppuccin_status_directory_text_bg "#{@thm_rosewater}"
          set -g @catppuccin_status_date_time_text_fg "#{@thm_crust}"
          set -g @catppuccin_status_date_time_text_bg "#{@thm_sapphire}"
          set -g @catppuccin_status_background "default"
          set -g @catppuccin_status_left_separator "█"
          set -g @catppuccin_status_right_separator "█"
        '';
      }
      pkgs.tmuxPlugins.resurrect
      {
        plugin = pkgs.tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore "on"
          set -g @continuum-save-interval "15"

          # Define status-right before continuum appends its autosave hook.
          # programs.tmux.extraConfig is emitted after plugins and would overwrite it.
          run-shell -b '${pkgs.vde-tmux}/bin/vt daemon ensure'

          set -g status-left-length 10000
          set -g status-style "fg=#{@thm_text},bg=#{@thm_base}"
          set -g status-left '#[default]#{@vde_status_sessions} #[default]#{@vde_status_windows}'
          set -ag status-left ' #{@vde_status_attention} #{@vde_status_summary}'
          set -g status-right-length 100
          set -g window-status-separator ""
          set -g status-right "#(${tmux-openrouter-credit}/bin/tmux-openrouter-credit)"
          set -ag status-right "#(${tmux-codex-usage}/bin/tmux-codex-usage)"
          set -ag status-right "#{E:@catppuccin_status_directory}"
          set -agF status-right "#{E:@catppuccin_status_date_time}"

          setw -g window-status-format ""
          setw -g window-status-current-format ""
        '';
      }
    ];

    baseIndex = 1;
    clock24 = true;
    customPaneNavigationAndResize = false;
    escapeTime = 10;
    focusEvents = true;
    historyLimit = 100000;
    keyMode = "vi";
    mouse = true;
    prefix = "C-b";
    terminal = "tmux-256color";

    extraConfig = ''
      set -s extended-keys on
      set -s extended-keys-format csi-u
      set -as terminal-features ',xterm*:extkeys'

      set -g pane-base-index 1
      set -g renumber-windows on

      bind n split-window -v -c "#{pane_current_path}"
      bind s split-window -v -c "#{pane_current_path}"
      bind S split-window -v -c "#{pane_current_path}"
      bind v split-window -h -c "#{pane_current_path}"

      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind C-h select-pane -L
      bind C-j select-pane -D
      bind C-k select-pane -U
      bind C-l select-pane -R
      # Ctrl+j is LF unless the terminal uses an extended key sequence.
      bind -n C-j if-shell -F '#{==:#{pane_current_command},opencode}' 'send-keys -H 1b 5b 31 30 36 3b 35 75' 'send-keys C-j'
      bind -n MouseDown1Status run-shell "${pkgs.vde-tmux}/bin/vt statusline-click --client-name #{q:client_name} --session-id #{q:session_id} #{q:mouse_status_range}"

      bind H swap-pane -t '{left-of}'
      bind J swap-pane -t '{down-of}'
      bind K swap-pane -t '{up-of}'
      bind L swap-pane -t '{right-of}'

      bind c kill-pane
      bind q kill-pane
      bind o display-popup -E -w 80% -h 70% -d "#{pane_current_path}" "${tmux-sesh}/bin/tmux-sesh"
      bind a run-shell '${pkgs.vde-tmux}/bin/vt sidebar focus-toggle --window #{q:window_id}'
      bind -n M-g display-popup -E -w 80% -h 70% -d "#{pane_current_path}" "${pkgs.lazygit}/bin/lazygit"
      bind -n M-i run-shell '${pkgs.editprompt}/bin/editprompt resume --target-pane #{pane_id} || tmux split-window -v -l 10 -c "#{pane_current_path}" "${pkgs.editprompt}/bin/editprompt open --always-copy --target-pane #{pane_id}"'

      bind C-w select-pane -t :.+
      bind w select-pane -t :.+
      bind W select-pane -t :.-
      bind p last-pane

      bind = select-layout even-horizontal
      bind + resize-pane -D 5
      bind - resize-pane -U 5
      bind < resize-pane -L 5
      bind > resize-pane -R 5

      bind _ resize-pane -Z
      bind | resize-pane -Z
      bind r rotate-window
      bind R rotate-window -D
      bind x swap-pane -D
      bind T break-pane

      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi C-v send -X rectangle-toggle

    '';
  };
}
