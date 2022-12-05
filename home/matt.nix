{ config, pkgs, lib, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
  dotfiles = /etc/nixos/nixfiles/dotfiles;

  # Zoom is doing something, pinning to an old version while it stabilizes

  zoomPin = import (builtins.fetchTarball {
    # Descriptive name to make the store path easier to identify
    name = "nixos-unstable-zoom-pin";
    url = "https://github.com/nixos/nixpkgs/archive/466c2e342a6887507fb5e58d8d29350a0c4b7488.tar.gz";
    # Hash obtained using `nix-prefetch-url --unpack <url>`
    sha256 = "0f3pc6rva386ywzh7dig5cppfw5y6kqc6krm5ksl012x3s61bzim";
  }) { config = { allowUnfree = true; }; };

in
{
  imports = [
    (import "${home-manager}/nixos")
  ];
    nixpkgs.overlays = [
      (import (builtins.fetchTarball {
        url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
      }))
      (import (builtins.fetchTarball {
        url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
      }))
    ];

  # TODO - add ktx
  # TODO - currently install doom-emacs and my config manually, make this automatic
  # TODO - fix bluetooth
  # TODO - tmux darker theme, maybe circle one?

  home-manager.users.matt = {
    # TODO - this is broken?
#    fonts.fontconfig.enable = true;
    services.syncthing = {
      enable = true;
      extraOptions = [
        "--config=/home/matt/.config/syncthing"
        "--data=/home/matt/Documents"
      ];
    };
    home = {
      stateVersion = "21.11";
      file = {
        ".p10k.zsh".source = dotfiles + /zsh/.p10k.zsh;
      };
      #file = {
      #  ".scripts/kns".source = dotfiles + /scripts/kns;
      #  # TODO - this is broken
      #  ".scripts/ktx".source = dotfiles + /scripts/ktx;
      #};
      packages = with pkgs; [
        autorandr
        bash
        bat
        brightnessctl
        #bundix
        cachix
        cloc
        colorls
        curl
        direnv
        docker-compose
        editorconfig-core-c
        emacs-all-the-icons-fonts
        expect
        fd
        feh
        file
        firefox
        flameshot
        fira-code
        fira-code-symbols
        inconsolata
        font-awesome
        fzf
        git
        gopls
        gotop
        google-chrome
        helm
        htop
        imagemagick
        ipcalc
        jq
        killall
        kubectl
        kubelogin
        kubelogin-oidc
        lazygit
        manix # provides NixOS completion for vim
        #unstable.neovim
        neovim-nightly
        nerdfonts
        ncdu
        nix-diff
        nix-index
        nvd
        openapi-generator-cli

        python310Packages.matplotlib
        python310Packages.opencv4
        python310Packages.numpy
        #opencv


        yarn
#        nodePackages.javascript-typescript-langserver
        pavucontrol
        paprefs
        pasystray
        pinta
        playerctl
        (polybar.override { i3Support = true; })
        postgresql
        powertop
        powerline-fonts
        powerline-symbols
        protobuf
        remmina
        (ripgrep.override { withPCRE2 = true; })
        simplescreenrecorder
        slack
        spotify
        sqlite
        super-slicer
#        steam-run # allows LHS app environment
        tmux
        tmuxp
        traceroute
        unzip
        vlc
        wget
        wpa_supplicant_gui
        zoomPin.zoom-us
#        zoom-us

        # i3wm stuff
        rofi
        dmenu
        i3status
        i3lock
      ];
    };

    programs = {
      alacritty = {
        enable = true;
      };

#      direnv = {
#        enable = true;
#        nix-direnv = {
#          enable = true;
#        };
#      };

      emacs = {
        enable = true;
        package = pkgs.emacsNativeComp;
      };

      git = {
        enable = true;
        userName = "mwdomino";
        userEmail = "mdominey@equinix.com";
        extraConfig = {
          url."ssh://git@github.com".insteadOf = "https://github.com";
        };
      };

      go = {
        enable = true;
      };

      tmux = {
        enable = true;
        clock24 = false;
        baseIndex = 1;
        prefix = "C-a";
        plugins = with pkgs.tmuxPlugins; [
          copycat
          sensible
          yank
          {
            plugin = dracula;
            extraConfig = ''
                set -g @dracula-plugins "battery"
                set -g @dracula-show-powerline true
              '';
          }
        ];
        extraConfig = ''
            set -g mouse on
            set -g history-limit 100000
            set-window-option -g mode-keys vi
            bind 'b' split-window -h
            bind 'v' split-window -v
            bind 'h' select-pane -L
            bind 'j' select-pane -D
            bind 'k' select-pane -U
            bind 'l' select-pane -R

            bind -n M-j previous-window
            bind -n M-k next-window

            unbind -T copy-mode-vi Space; #Default for begin-selection
            unbind -T copy-mode-vi Enter; #Default for copy-selection
            bind -T copy-mode-vi v send-keys -X begin-selection
            bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xclip -i -f -selection primary | xclip -i -selection clipboard"`

            set -g default-terminal "screen-256color"
            set-option -g default-terminal "screen-256color"
            set-option -sa terminal-overrides ',alacritty:RGB'
          '';
      };

      zsh = {
        enable = true;
        enableAutosuggestions = true;
        oh-my-zsh = {
          enable = true;
          plugins = [
            "command-not-found"
            "git"
            "fzf"
            "ripgrep"
            "docker"
            "docker-compose"
          ];
          extraConfig = ''
            source ~/.p10k.zsh
          '';
        };
        plugins = [
          {
            name = "zsh-syntax-highlighting";
            src = pkgs.fetchFromGitHub {
              owner = "zsh-users";
              repo = "zsh-syntax-highlighting";
              rev = "2d60a47cc407117815a1d7b331ef226aa400a344";
              sha256 = "1pnxr39cayhsvggxihsfa3rqys8rr2pag3ddil01w96kw84z4id2";
            };
          }
          {
            name = "zsh-nix-shell";
            file = "nix-shell.plugin.zsh";
            src = pkgs.fetchFromGitHub {
              owner = "chisui";
              repo = "zsh-nix-shell";
              rev = "v0.5.0";
              sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
            };
          }
          {
            name = "powerlevel10k";
            src = pkgs.zsh-powerlevel10k;
            file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
          }
        ];
        sessionVariables = rec {
          DIRENV_LOG_FORMAT = "";
          EDITOR = "emacs -nw";
          FZF_DEFAULT_OPTS = "--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4";
          GOPROXY = "direct";
          GOPRIVATE = "github.com/packethost/*";
          PATH = "/home/matt/go/bin:/home/matt/.scripts:$PATH";
          VISUAL = "nvim";
          WINIT_X11_SCALE_FACTOR = "1";
        };
        shellAliases = {
          bat = "bat --theme=\"Dracula\"";
          cat = "bat --theme=\"Dracula\"";
          dock = "xrandr --output eDP-1 --off --output DP-2 --off --output DP-1 --primary --mode 3840x2160 --pos 0x0 --rotate normal --scale 0.75x0.75 --output DP-3 --off && setbg";
          e = "$EDITOR";
          jqe = "echo '' | fzf --preview 'jq {q} < filename.json'";
          kc = "kubectl";
          ls = "colorls --sd --dark";
          setbg = "feh --bg-fill /home/matt/Pictures/wallpaper.png";
          t = "tmuxp load";
          tree = "colorls --sd -dark --tree";
          undock = "xrandr --output eDP-1 --primary --mode 1920x1200 --pos 0x0 --rotate normal --output DP-1 --off --output DP-2 --off --output DP-3 --off && setbg";
          vim = "nvim";
          vpn_up = "expect /home/matt/.vpnexpect openvpn-new-admin-vpn";
          vpn_down = "sudo systemctl stop openvpn-new-admin-vpn";
          vpn_bounce = "vpn_down; sleep 1; vpn_up";
        };
      };
    };

    xdg = {
      configFile = {
        "alacritty/alacritty.yml".source = dotfiles + /alacritty/alacritty.yml;
        "autorandr".source = dotfiles + /autorandr;
        "colorls/dark_colors.yaml".source = dotfiles + /colorls/dark_colors.yaml;
        "i3/config".source = dotfiles + /i3/config;
        "nixpkgs/config.nix".source = dotfiles + /nixpkgs/config.nix;
        "polybar".source = dotfiles + /polybar;
        "rofi".source = dotfiles + /rofi;
        "tmuxp".source = dotfiles + /tmuxp;
      };
    };
  };
}
