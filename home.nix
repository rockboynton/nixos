{ pkgs, config, inputs, ... }:

let
  username = "rockboynton";
  nixosConfigDir = "${config.home.homeDirectory}/sources/nixos";
in
{
  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "24.11";

    file.".config/helix/" = {
      source = config.lib.file.mkOutOfStoreSymlink "${nixosConfigDir}/helix/";
      recursive = true;
    };

    file.".config/starship.toml".source = config.lib.file.mkOutOfStoreSymlink "${nixosConfigDir}/starship/starship.toml";

    file.".config/zellij/" = {
      source = config.lib.file.mkOutOfStoreSymlink "${nixosConfigDir}/zellij/";
      recursive = true;
    };

    file.".config/wezterm/wezterm.lua".source = config.lib.file.mkOutOfStoreSymlink "${nixosConfigDir}/wezterm/wezterm.lua";

    packages = with pkgs;
      [
        bat
        bat-extras.batman
        bottom
        delta
        direnv
        dust
        fd
        fish
        fzf
        gitui
        google-chrome
        jq
        lazygit
        lsd
        neofetch
        neovim
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
        tealdeer
        thefuck
        tokei
        tree
        unzip
        usbutils
        wezterm
        which
        yazi
        # zellij
        zip
        zoxide
      ];
  };

  programs = {
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
      '';
      shellAbbrs = {
        nrs = "nixos-rebuild switch --use-remote-sudo";
        zj = "zellij";
        ns = "nix shell nixpkgs#";
        yz = "yazi";
        gt = "gitui";
        fixup = "git add -u && git commit --amend --no-edit && git push -f";
        hxu = "~/sources/scripts/open-in-helix-under";
        copy = "sed -z '\$ s/\n\$//' | ssh rboynton-macbook14.corp.anduril.com pbcopy";
        l = "ls -a";
        la = "ls -a";
        lla = "ls -la";
        lt = "ls --tree";
        gs = "git status";
        gc = "git commit";
        gca = "git commit --amend";
        gcan = "git commit --amend --no-edit";
        gpull = "git pull";
        gpush = "git push";
        gpf = "git push --force-with-lease";
        gpr = "git pull --rebase origin master";
        glog = "git log";
        gl = "git lg";
        gf = "git fetch";
        gco = "git checkout";
        gcob = "git checkout -b";
        ga = "git add";
        gr = "git rebase";
        gra = "git rebase --abort";
        grc = "git rebase --continue";
        grs = "git reset --hard";
        gd = "git diff";
        gds = "DELTA_FEATURES=+side-by-side git diff";
        glast = "git rev-parse HEAD";
        man = "batman";
        cd = "z";
        da = "direnv allow";
        dr = "direnv reload";

        # fixup = 
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
          # pager = ":builtin";
          pager = "delta";
          diff.format = "git";
        };
      };
    };

    git = {
      enable = true;
      delta = {
        enable = true;
        options = {
          syntax-theme = "gruvbox-dark";
          true-color = "always";
          line-numbers = true;
        };
      };
      userName = "Rock Boynton";
      userEmail = "rock.boynton@yahoo.com";
      extraConfig = {
        commit.gpgsign = true;
        gpg.format = "ssh";
        user.signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICsfk0fRSkV21MX4xmXqPXxf25zcDOpOwKSmM9cMwVmu rock.boynton@yahoo.com";
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      # enableFishIntegration = true;
    };

    fzf = {
      enable = true;
      enableFishIntegration = true;
    };

    thefuck = {
      enable = true;
      enableFishIntegration = true;
    };

    zellij = {
      enable = true;
      enableFishIntegration = true;
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}

