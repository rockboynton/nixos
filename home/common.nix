{ pkgs, lib, config, inputs, ... }:

let
  nixosConfigDir = "${config.home.homeDirectory}/sources/nixos";
  system = pkgs.stdenv.hostPlatform.system;
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
in
{
  home = {
    stateVersion = "24.11";

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

    file.".config/ghostty/config".source = mkOutOfStoreSymlink "${nixosConfigDir}/ghostty/config";

    file.".config/jj/config.toml".source = mkOutOfStoreSymlink "${nixosConfigDir}/jj/config.toml";

    file.".config/jjui/config.toml".source = mkOutOfStoreSymlink "${nixosConfigDir}/jjui/config.toml";

    file.".face".source = mkOutOfStoreSymlink "${nixosConfigDir}/.face";

    file.".config/rumdl.toml".source = mkOutOfStoreSymlink "${nixosConfigDir}/rumdl/rumdl.toml";

    packages = with pkgs;
      [
        bat-extras.batman
        bottom
        delta
        direnv
        dust
        helvetica-neue-lt-std
        aileron
        fira
        roboto
        fastfetch
        fd
        fish
        fzf
        gh
        gitui
        harper
        jj-starship
        jq
        jjui
        jujutsu
        lazygit
        lsd
        mergiraf
        nix-prefetch-git
        nixd
        nix-direnv
        nix-output-monitor
        nixpkgs-fmt
        patchy
        ripgrep
        rumdl
        taplo
        tealdeer
        tokei
        tree
        treefmt
        unzip
        which
        zip
        zoxide
      ];
  };

  programs = {
    home-manager.enable = true;

    yazi = {
      enable = true;
      enableFishIntegration = true;
      shellWrapperName = "yy";
    };

    helix = {
      enable = true;
      package = inputs.helix.packages.${system}.helix;
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

        set -gx COLORTERM truecolor
        set -gx STARSHIP_LOG error

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

        function starship_transient_prompt_func
          starship module time
          starship module character
        end

        set -g FZF_CTRL_T_COMMAND "command find -L \$dir -type f 2> /dev/null | sed '1d; s#^\./##'"
        set FZF_CTRL_T_OPTS " \
          --walker-skip .git,node_modules,target \
          --preview 'bat -n --color=always --theme=gruvbox-dark {}' \
          --bind 'ctrl-/:change-preview-window(down|hidden|)'"

        if not set -q ZELLIJ
          zellij attach dev -c
        end
      '';
      shellAbbrs = {
        nfu = "nix flake update";
        zj = "zellij";
        ns = "nix shell nixpkgs#";
        yz = "yazi";
        gt = "gitui";
        hxu = "~/sources/scripts/open-in-helix-under";
        l = "ls -a";
        la = "ls -a";
        lla = "ls -la";
        lt = "ls --tree";
        jd = "jj diff --tool delta";
        jds = "jj diff";
        ju = "jj tug && jj push";
        jl = "jj log";
        jsq = "jj squash";
        js = "jj status";
        jst = "jj status";
        jp = "jj push";
        jf = "jj fetch";
        jfa = "jj fetch --all-remotes";
        je = "jj edit";
        jn = "jj new";
        ja = "jj abandon";
        jr = "jj restore";
        jt = "jj tug";
        jc = "jj commit";
        jo = "jj op";
        jrb = "jj rebase";
        jsh = "jj show";
        jsp = "jj squash && jj push";
        jdst = "jj diff --stat";
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
        jjw = {
          description = "Describe a jj change and create a bookmark, optionally in a new workspace";
          body = /* fish */ ''
            argparse -x 'w,d' 'w/workspace' 'd/done' -- $argv
            or return 1

            if set -q _flag_done
                set -l ws_path (jj workspace root)
                or return 1

                set -l ws_name (jj workspace list -T 'name ++ " " ++ self.root() ++ "\n"' | \
                                awk -v p="$ws_path" '$2 == p { print $1 }')

                if test -z "$ws_name"; or test "$ws_name" = default
                    echo "jjw -d: not inside a named workspace (current: '$ws_name'). Refusing."
                    return 1
                end

                set -l ws_parent (dirname "$ws_path")
                set -l ws_base (basename "$ws_path")
                set -l main_base (string replace -r -- "-$ws_name\$" "" "$ws_base")
                if test "$main_base" = "$ws_base"
                    echo "jjw -d: current path basename '$ws_base' does not end with '-$ws_name'; can't locate main repo."
                    return 1
                end
                set -l main_path "$ws_parent/$main_base"
                if not test -d "$main_path/.jj"
                    echo "jjw -d: expected main repo at $main_path but .jj is missing."
                    return 1
                end

                read -P "Delete workspace '$ws_name' at $ws_path? [y/N] " -l confirm
                if not string match -qr '^[yY]' -- $confirm
                    echo "Aborted."
                    return 1
                end

                cd "$main_path"
                or return 1
                jj workspace forget $ws_name
                or return 1
                rm -rf "$ws_path"
                or return 1
                if test -n "$ZELLIJ"
                    zellij action rename-tab "$main_base"
                end
                return 0
            end

            if test (count $argv) -lt 1
                echo "jjw — describe a jj change and bookmark it."
                echo
                echo "Usage:"
                echo "  jjw \"Description\"        Bookmark @ and start an empty follow-up change."
                echo "  jjw -w \"Description\"     Also spin up a sibling workspace from trunk() and cd in."
                echo "  jjw -d                   Forget the current workspace and return to the main repo."
                return 1
            end

            set -l description $argv[1]
            set -l bookmark_id (string lower -- $description | \
                                string replace -ra '[^a-z0-9]+' '-' | \
                                string trim --chars=-)

            if set -q _flag_workspace
                set -l repo_root (jj root)
                or return 1
                set -l parent (dirname "$repo_root")
                set -l repo_base (basename "$repo_root")
                set -l ws_path "$parent/$repo_base-$bookmark_id"

                jj workspace add --sparse-patterns "full" --name $bookmark_id -r 'trunk()' "$ws_path" --quiet
                or return 1

                begin
                    git -C "$repo_root" ls-files -z --others --exclude-standard -- ':!.jj'
                    git -C "$repo_root" ls-files -z --others --ignored --exclude-standard -- ':!.jj'
                end | grep -zEv '(^|/)target/|(^|/)\.direnv/|^\.rumdl_cache/' \
                   | while read -z f
                        set -l full "$repo_root/$f"
                        if test -L "$full"; and string match -q '/nix/store/*' (readlink "$full")
                            continue
                        end
                        printf '%s\0' "$f"
                    end \
                   | rsync -a --from0 --files-from=- --info=progress2 \
                           "$repo_root/" "$ws_path/"
                or return 1

                for gi in (find "$repo_root" -maxdepth 2 -name .gitignore -not -path '*/.jj/*')
                    set -l rel (string replace "$repo_root/" "" "$gi")
                    set -l dest "$ws_path/"(string replace '.gitignore' '.ignore' "$rel")
                    cp "$gi" "$dest" 2>/dev/null
                end

                cd "$ws_path"
                or return 1
            end

            if test -n "$ZELLIJ"
                zellij action rename-tab $bookmark_id
            end

            jj bookmark create -r @ "$USER/$bookmark_id" --quiet
            jj describe -m $description --quiet

            jj new
          '';
        };
      };
    };

    bat.enable = true;

    jujutsu.enable = true;

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
      signing.format = "openpgp";
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
      config.global.hide_env_diff = true;
    };

    fzf = {
      enable = true;
      enableFishIntegration = true;
    };

    zellij.enable = true;

    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
