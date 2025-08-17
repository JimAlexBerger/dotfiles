{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    clock24 = true;
    shortcut = "Space";
    baseIndex = 1;

    tmuxp.enable = true;

    plugins = with pkgs; [
      tmuxPlugins.sensible
      tmuxPlugins.catppuccin
      tmuxPlugins.better-mouse-mode
      tmuxPlugins.yank
      tmuxPlugins.vim-tmux-navigator
    ];

    extraConfig = ''
      # Colors
      set -ga terminal-overrides ",xterm*:Tc"

      # Mouse support
      set-option -g mouse on

      #New panes in current path
      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      
      # Display Popups
      bind C-y display-popup \
        -d "#{pane_current_path}" \
        -w 80% \
        -h 80% \
        -E "lazyjj"
      bind C-n display-popup -E 'bash -i -c "read -p \"Session name: \" name; tmux new-session -d -s \$name && tmux switch-client -t \$name"'
      bind C-j display-popup -E "tmux list-sessions | sed -E 's/:.*$//' | grep -v \"^$(tmux display-message -p '#S')\$\" | fzf --reverse | xargs tmux switch-client -t"
      bind C-s display-popup \
        -w 80% \
        -h 80% \
        -E "spotify_player"
      bind C-h display-popup -E "nh home switch -b backup"
      bind C-t display-popup -E "zsh"

      # Catppuccin status bar
      set -g @catppuccin_window_left_separator "█"
      set -g @catppuccin_window_right_separator "█ "
      set -g @catppuccin_window_number_position "right"
      set -g @catppuccin_window_middle_separator "  █"

      set -g @catppuccin_window_default_fill "number"

      set -g @catppuccin_window_current_fill "number"
      set -g @catppuccin_window_current_text "#{pane_current_path}"

      set -g @catppuccin_status_modules_right "application session date_time"
      set -g @catppuccin_status_left_separator  ""
      set -g @catppuccin_status_right_separator " "
      set -g @catppuccin_status_fill "all"
      set -g @catppuccin_status_connect_separator "yes"
    '';
  };

  
  home.file.".config/tmuxp/develop-oddjob.yaml" = {
    source = ./develop-oddjob.yaml;
  };

}
