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
      nil
      nix-direnv
      fd
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
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        format = "$username$os$all";
        username = {
          style_user = "bold blue";
          show_always = true;
          format = "[$user]($style) ";
        };
        os = {
          style = "bold bright-black";
          disabled = false;
          format = "with [$symbol]($style)";
          symbols = {
            NixOS = " ";
            Macos = " ";
          };
        };
        directory = {
          truncate_to_repo = false;
          truncation_symbol = ".../";
          read_only = " 󰌾";
          format = " in [$path]($style)[$read_only]($read_only_style) ";
        };
        aws = {
          format = "on [$symbol$profile]($style) ";
          symbol = "";
        };
        git_branch = {
          symbol = " ";
        };
        nix_shell = {
          symbol = "󱄅 ";
        };
        haskell = {
          symbol = " ";
        };
        lua = {
          symbol = " ";
        };
        python = {
          symbol = " ";
        };
        rust = {
          symbol = " ";
        };
        zig = {
          symbol = " ";
        };
      };
    };

    thefuck = {
      enable = true;
      enableZshIntegration = true;
    };

    zellij = {
      enable = true;
      enableZshIntegration = true;
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}

