{
  programs.tmux = {
    enable = true;

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

      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi C-v send -X rectangle-toggle
    '';
  };
}
