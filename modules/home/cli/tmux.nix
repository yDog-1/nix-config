{
  config,
  pkgs,
  ...
}: let
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
in {
  home.packages = [
    pkgs.ai-usagebar
    pkgs.sesh
    tmux-codex-usage
    tmux-openrouter-credit
  ];

  sops.secrets.openrouter_api_key = {};

  programs.tmux = {
    enable = true;

    plugins = [
      pkgs.tmuxPlugins.resurrect
      {
        plugin = pkgs.tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-strategy-nvim 'session'
        '';
      }
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

      bind H swap-pane -t '{left-of}'
      bind J swap-pane -t '{down-of}'
      bind K swap-pane -t '{up-of}'
      bind L swap-pane -t '{right-of}'

      bind c kill-pane
      bind q kill-pane
      bind o kill-pane -a

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

      bind C-s display-popup -E "${pkgs.sesh}/bin/sesh connect \"$(${pkgs.sesh}/bin/sesh list -i | ${pkgs.fzf}/bin/fzf --prompt='sesh> ' --height=40% --layout=reverse --border)\""

      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi C-v send -X rectangle-toggle

      set -g status-left ""
      set -g status-left-length 100
      set -g status-right-length 100
      set -g window-status-separator ""
      set -g status-right "#(${tmux-openrouter-credit}/bin/tmux-openrouter-credit)"
      set -ag status-right "#(${tmux-codex-usage}/bin/tmux-codex-usage)"
      set -ag status-right "#{E:@catppuccin_status_directory}"
      set -agF status-right "#{E:@catppuccin_status_date_time}"
    '';
  };
}
