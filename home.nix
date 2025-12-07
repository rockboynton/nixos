{ pkgs, lib, config, inputs, ... }:

let
  username = "rockboynton";
  nixosConfigDir = "${config.home.homeDirectory}/sources/nixos";
  localPackages = import ./pkgs { inherit pkgs; };
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
  # chrome =
  #   (pkgs.writeShellScriptBin "chrome" ''
  #     exec ${lib.getExe pkgs.google-chrome} \
  #       --enable-features=ProactiveTabFreezeAndDiscard,TabFreeze,TabDiscarding,BackForwardCache,VaapiVideoDecodeLinuxGL \
  #       --enable-aggressive-domstorage-flushing \
  #       --ozone-platform=wayland \
  #       "$@"
  #   '');
in
{
  imports = [ inputs.walker.homeManagerModules.default ];

  systemd.user.services = {
    swayidle = {
      Unit = {
        Description = "Idle manager for Niri";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = lib.concatStringsSep " " [
          "${lib.getExe pkgs.swayidle} -d"
          "timeout 240 'notify-send --app-name \"Idle Warning\" \"System will lock soon due to inactivity.\"'"
          "timeout 300 'noctalia-shell ipc call lockScreen lock'"
          "timeout 600 'niri msg action power-off-monitors'"
          "resume 'niri msg action power-on-monitors'"
          "timeout 900 'systemctl suspend'"
          "before-sleep 'noctalia-shell ipc call lockScreen lock'"
        ];
        Restart = "on-failure";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };

  # xdg.desktopEntries.google-chrome = {
  #   name = "Google Chrome";
  #   exec = "chrome %U";
  #   icon = "google-chrome";
  #   type = "Application";
  #   categories = [ "Network" "WebBrowser" ];
  #   mimeType = [ "text/html" "text/xml" "application/xhtml+xml" "x-scheme-handler/http" "x-scheme-handler/https" ];
  # };

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "24.11";

    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    pointerCursor = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
      x11.enable = true;
      gtk.enable = true;
    };

    file."backgrounds" = {
      source = mkOutOfStoreSymlink "${nixosConfigDir}/backgrounds/";
      recursive = true;
    };

    file.".config/helix/" = {
      source = mkOutOfStoreSymlink "${nixosConfigDir}/helix/";
      recursive = true;
    };

    file.".config/starship.toml".source = mkOutOfStoreSymlink "${nixosConfigDir}/starship/starship.toml";

    file.".config/zellij/" = {
      source = mkOutOfStoreSymlink "${nixosConfigDir}/zellij/";
      recursive = true;
    };

    file.".config/wezterm/wezterm.lua".source = mkOutOfStoreSymlink "${nixosConfigDir}/wezterm/wezterm.lua";

    # `elephant` doesn't currently abide by FHS: https://github.com/abenz1267/elephant/issues/137 
    file.".config/elephant/clipboard.toml".source = mkOutOfStoreSymlink "${nixosConfigDir}/elephant/clipboard.toml";

    file.".face".source = mkOutOfStoreSymlink "${nixosConfigDir}/.face";

    file.".config/walker/" = {
      source = mkOutOfStoreSymlink "${nixosConfigDir}/walker";
      recursive = true;
    };

    file.".config/niri/" = {
      source = mkOutOfStoreSymlink "${nixosConfigDir}/niri/";
      recursive = true;
    };

    file.".config/noctalia/" = {
      source = mkOutOfStoreSymlink "${nixosConfigDir}/noctalia/";
      recursive = true;
    };

    packages = with pkgs;
      [
        _1password-gui
        alacritty
        bat
        bat-extras.batman
        bottom
        caprine
        # chrome
        delta
        direnv
        discord
        dust
        element-desktop
        fd
        fish
        fzf
        gh
        gitui
        google-chrome
        inputs.noctalia.packages.${pkgs.system}.default
        inputs.modeling-app.packages.${pkgs.system}.kcl-language-server
        inputs.zoo-cli.packages.${pkgs.system}.zoo
        jjui
        jq
        lazygit
        libnotify
        localPackages.zoo-design-studio
        lsd
        nautilus
        neofetch
        nerd-fonts.fira-code
        nixd
        nix-direnv
        nix-output-monitor
        nixpkgs-fmt
        patchy
        qmk
        qmk-udev-rules
        ripgrep
        starship
        swayidle
        tealdeer
        tokei
        tree
        unzip
        usbutils
        wezterm
        which
        wl-clipboard
        wtype
        xwayland-satellite
        zip
        zoxide
      ];
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts.monospace = [ "FiraCode Nerd Font" ];
  };

  services = {
    clipcat = {
      enable = true;
      enableZshIntegration = true;
      enableSystemdUnit = true;
    };
  };

  programs = {
    rio.enable = true;
    walker = {
      enable = true;
      runAsService = true;
      # Empty config to prevent the default one from being generated (use the config from this repo)
      config = { };
    };
    yazi = {
      enable = true;
      enableFishIntegration = true;
      package = inputs.yazi.packages.${pkgs.system}.yazi;
    };
    home-manager.enable = true;
    helix = {
      enable = true;
      package = inputs.helix.packages.${pkgs.system}.helix;
      defaultEditor = true;
    };
    starship = {
      enable = true;
      enableFishIntegration = true;
      enableTransience = true;
    };

    fish = {
      enable = true;
      interactiveShellInit = /* fish */ ''
        # use empty greeting
        set fish_greeting 

        # custom gruvbox theme
        set_gruvbox_theme
        
        # use vi keybindings, but inherit emacs keybindings too
        fish_hybrid_key_bindings

        # emulate the vi cursor shape behavior
        set fish_vi_force_cursor 1
        fish_vi_cursor
        set fish_cursor_default block
        set fish_cursor_insert line
        set fish_cursor_replace_one underscore
        set fish_cursor_replace underscore
        set fish_cursor_external line

        function starship_transient_rprompt_func
          starship module line_break
          starship module time
        end

        if not set -q ZELLIJ
          zellij attach dev -c
        end
      '';
      shellAbbrs = {
        nrs = "sudo nixos-rebuild switch";
        zj = "zellij";
        ns = "nix shell nixpkgs#";
        yz = "yazi";
        gt = "gitui";
        hxu = "~/sources/scripts/open-in-helix-under";
        l = "ls -a";
        la = "ls -a";
        lla = "ls -la";
        lt = "ls --tree";
        jd = "jj diff";
        jds = "DELTA_FEATURES=+side-by-side jj diff";
        ju = "jj tug && jj push";
        jl = "jj log";
        jsq = "jj squash";
        jst = "jj status";
        jp = "jj push";
        jf = "jj fetch";
        jfa = "jj fetch --all-remotes";
        je = "jj edit";
        jn = "jj new";
        glast = "git rev-parse HEAD";
        man = "batman";
        cd = "z";
        da = "direnv allow";
        dr = "direnv reload";
      };
      shellAliases = {
        ls = "lsd --group-directories-first";
      };
      functions = {
        set_gruvbox_theme = {
          body = /* fish */ ''
            # Gruvbox color palette with medium contrast
            set -l gruvbox_bg 282828     # Dark background
            set -l gruvbox_fg ebdbb2     # Light foreground
            set -l gruvbox_bg0_h 1d2021  # Darker background
            set -l gruvbox_bg1 3c3836  # Lighter background
            set -l gruvbox_fg4 a89984  # Dark foreground
            set -l gruvbox_gray 928374   # Gray
            set -l gruvbox_red cc241d    # Red
            set -l gruvbox_green 98971a  # Green
            set -l gruvbox_yellow d79921 # Yellow
            set -l gruvbox_blue 458588   # Blue
            set -l gruvbox_purple b16286 # Purple
            set -l gruvbox_aqua 689d6a   # Aqua
            set -l gruvbox_orange d65d0e # Orange

            # Bright variants
            set -l gruvbox_red_bright fb4934    # Bright red
            set -l gruvbox_green_bright b8bb26  # Bright green
            set -l gruvbox_yellow_bright fabd2f # Bright yellow
            set -l gruvbox_blue_bright 83a598   # Bright blue
            set -l gruvbox_purple_bright d3869b # Bright purple
            set -l gruvbox_aqua_bright 8ec07c   # Bright aqua
            set -l gruvbox_orange_bright fe8019 # Bright orange

            # Use defined colors from the Gruvbox palette
            set -g fish_color_normal $gruvbox_fg
            set -g fish_color_command $gruvbox_green --bold
            set -g fish_color_keyword $gruvbox_red --bold
            set -g fish_color_quote $gruvbox_green_bright
            set -g fish_color_redirection $gruvbox_orange
            set -g fish_color_end $gruvbox_orange
            set -g fish_color_error $gruvbox_red_bright --italics
            set -g fish_color_param $gruvbox_blue
            set -g fish_color_comment $gruvbox_gray
            set -g fish_color_match --background=$gruvbox_bg0_h
            set -g fish_color_search_match --background=$gruvbox_yellow --foreground=$gruvbox_bg
            set -g fish_color_selection --background=$gruvbox_bg1 --foreground=$gruvbox_yellow_bright
            set -g fish_color_history_current --background=$gruvbox_bg1
            set -g fish_color_operator $gruvbox_aqua
            set -g fish_color_escape $gruvbox_purple_bright
            set -g fish_color_valid_path $gruvbox_blue_bright --underline
            set -g fish_color_option $gruvbox_yellow --italics
            set -g fish_color_autosuggestion $gruvbox_fg4
            set -g fish_color_cancel $gruvbox_orange_bright --reverse

            set -g fish_pager_color_description '$yellow'  '-i'
            set -g fish_pager_color_prefix 'normal'  '--bold'  '--underline'
            set -g fish_pager_color_progress '--background=cyan'
            set -g fish_pager_color_selected_background -r
          '';
        };
      };

    };

    bat = {
      enable = true;
    };

    jujutsu = {
      package = inputs.jj.outputs.packages.${pkgs.stdenv.hostPlatform.system}.jujutsu;
      enable = true;
      settings = {
        user = {
          name = "Rock Boynton";
          email = "rock.boynton@yahoo.com";
        };
        ui = {
          merge-editor = ":builtin";
          pager = "delta";
          diff-formatter = ":git";
        };
        revset-aliases = {
          "closest_bookmark(to)" = "heads(::to & bookmarks())";
        };
        aliases = {
          tug = [ "bookmark" "move" "--from" "closest_bookmark(@-)" "--to" "@-" ];
          push = [ "git" "push" ];
          fetch = [ "git" "fetch" ];
        };
      };
    };

    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        syntax-theme = "gruvbox-dark";
        true-color = "always";
        line-numbers = true;
      };
    };

    git = {
      enable = true;
      settings = {
        user.name = "Rock Boynton";
        user.email = "rock.boynton@yahoo.com";
        commit.gpgsign = true;
        gpg.format = "ssh";
        user.signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICsfk0fRSkV21MX4xmXqPXxf25zcDOpOwKSmM9cMwVmu rock.boynton@yahoo.com";
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    fzf = {
      enable = true;
      enableFishIntegration = true;
    };

    zellij = {
      enable = true;
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}

