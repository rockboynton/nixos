{ pkgs, ... }:

{
  home = rec {
    username = "rockboynton";
    homeDirectory = "/home/${username}";
    stateVersion = "23.11";
    packages = with pkgs; [
      bat
      bottom
      direnv
      dust
      neofetch
      neovim
      nerdfonts
      nix-direnv
      fd
      fish
      fzf
      helix
      jq
      lsd
      nix-output-monitor
      ripgrep
      tree
      starship
      tealdeer
      thefuck
      tokei
      unzip
      usbutils
      wezterm
      which
      zip
      zellij
      zoxide
      zsh
    ];
  };

  programs = {
    home-manager.enable = true;

    helix = {
      enable = true;
      settings = {
        theme = "gruvbox";
        editor = {
          line-number = "relative";
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
          file-picker.hidden = false;
        };
      };
      defaultEditor = true;
      languages = {
        language = [
          {
            name = "nix";
            formatter = { command = "nixpkgs-fmt"; };
            auto-format = true;
          }
        ];
      };
    };

    fish = {
      enable = true;
      interactiveShellInit = ''
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
        "nrs" = "nixos-rebuild switch --use-remote-sudo";
      };
      functions = {
        set_gruvbox_theme = {
          body = ''
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
            set -g fish_color_command $gruvbox_blue --bold
            set -g fish_color_keyword $gruvbox_red --bold
            set -g fish_color_quote $gruvbox_green_bright
            set -g fish_color_redirection $gruvbox_orange
            set -g fish_color_end $gruvbox_orange
            set -g fish_color_error $gruvbox_red_bright --italics
            set -g fish_color_param $gruvbox_fg
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

    wezterm = {
      enable = true;
      enableZshIntegration = true;
      extraConfig = builtins.readFile ./.wezterm.lua;
    };

    zsh = {
      enable = true;
      autosuggestion.enable = true;
      # defaultKeymap = "viins";
      enableCompletion = true;
      history.expireDuplicatesFirst = true;
      shellAliases = {
        fixup = "git add -u && git commit --amend --no-edit && git push -f";
        zj = "zellij";
        ncu = "nixos-rebuild switch --use-remote-sudo";
      };
      syntaxHighlighting = {
        enable = true;
        highlighters = [
          "main"
          "brackets"
        ];
      };
    };

    git = {
      enable = true;
      userName = "Rock Boynton";
      userEmail = "rock.boynton@yahoo.com";
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
      # enableFishIntegration = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableTransience = true;
      settings = {
        palette = "gruvbox_dark";
        palettes.gruvbox_dark = {
          color_fg0 = "#fbf1c7";
          color_bg1 = "#3c3836";
          color_bg3 = "#665c54";
          color_blue = "#458588";
          color_aqua = "#689d6a";
          color_green = "#98971a";
          color_orange = "#d65d0e";
          color_purple = "#b16286";
          color_red = "#cc241d";
          color_yellow = "#d79921";
        };
        format = builtins.concatStringsSep "" [
          "[](color_orange)"
          "$os"
          "$username"
          "[](bg:color_yellow fg:color_orange)"
          "$directory"
          "[](fg:color_yellow bg:color_aqua)"
          "$git_branch"
          "$git_status"
          "$git_state"
          "[](fg:color_aqua bg:color_blue)"
          "$c"
          "$rust"
          "$haskell"
          "$python"
          "[](fg:color_blue bg:color_bg3)"
          "$nix_shell"
          "[](fg:color_bg3 bg:color_bg1)"
          "$time"
          "$cmd_duration"
          "[ ](fg:color_bg1)"
          "$line_break$character"
        ];
        os = {
          disabled = false;
          style = "bg:color_orange fg:color_fg0";
          symbols = {
            NixOS = " ";
            Macos = " ";
          };
        };
        username = {
          show_always = true;
          style_user = "bg:color_orange fg:color_fg0";
          style_root = "bg:color_orange fg:color_fg0";
          format = "[ $user ]($style)";
        };

        directory = {
          style = "fg:color_fg0 bg:color_yellow";
          format = "[ $path ]($style)";
          truncation_length = 3;
          truncation_symbol = "…/";
        };

        git_branch = {
          symbol = "";
          style = "bg:color_aqua";
          format = "[[ $symbol $branch ](fg:color_fg0 bg:color_aqua)]($style)";
        };

        git_status = {
          style = "bg:color_aqua";
          format = "[[($all_status$ahead_behind )](fg:color_fg0 bg:color_aqua)]($style)";
        };

        git_state = {
          style = "bg:color_aqua";
          format = "[[\\($state( $progress_current/$progress_total)\\)](fg:color_yellow bg:color_aqua)]($style)";
        };

        c = {
          symbol = " ";
          style = "bg:color_blue";
          format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
        };

        rust = {
          symbol = "";
          style = "bg:color_blue";
          format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
        };

        haskell = {
          symbol = "";
          style = "bg:color_blue";
          format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
        };

        python = {
          symbol = "";
          style = "bg:color_blue";
          format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
        };

        nix_shell = {
          symbol = "󱄅";
          style = "bg:color_blue";
          format = "[[ $symbol $state( \\($name\\))](fg:#83a598 bg:color_bg3)]($style)";
          heuristic = true;
        };

        time = {
          disabled = false;
          time_format = "%R";
          style = "bg:color_bg1";
          format = "[[  $time ](fg:color_fg0 bg:color_bg1)]($style)";
        };

        cmd_duration = {
          style = "bg:color_bg1";
          format = "[[ took $duration ](fg:color_yellow bg:color_bg1)]($style)";
        };

        line_break = {
          disabled = false;
        };

        character = {
          disabled = false;
          success_symbol = "[󱞩](bold fg:color_green)";
          error_symbol = "[󱞩](bold fg:color_red)";
          vimcmd_symbol = "[](bold fg:color_green)";
          vimcmd_replace_one_symbol = "[](bold fg:color_yellow)";
          vimcmd_replace_symbol = "[](bold fg:color_orange)";
          vimcmd_visual_symbol = "[](bold fg:color_purple)";
        };
      };
    };

    thefuck = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };

    zellij = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };
  };
}

