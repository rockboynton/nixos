{ pkgs, lib, config, inputs, ... }:

let
  nixosConfigDir = "${config.home.homeDirectory}/sources/nixos";
  localPackages = import ../pkgs { inherit pkgs; };
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
  system = pkgs.stdenv.hostPlatform.system;
in
{
  imports = [
    ./common.nix
    inputs.walker.homeManagerModules.default
  ];

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

  gtk = {
    enable = true;
    gtk4.theme = config.gtk.theme;
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
  };

  home = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_QPA_PLATFORMTHEME = "gtk3";
    };

    pointerCursor = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
      x11.enable = true;
      gtk.enable = true;
    };

    # elephant doesn't currently abide by FHS: https://github.com/abenz1267/elephant/issues/137
    file.".config/elephant/clipboard.toml".source = mkOutOfStoreSymlink "${nixosConfigDir}/elephant/clipboard.toml";

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
        adwaita-icon-theme
        alacritty
        caprine
        discord
        element-desktop
        firefox
        gimp
        google-chrome
        gtk3
        inputs.modeling-app.packages.${system}.kcl-language-server
        inputs.zoo-cli.packages.${system}.zoo
        localPackages.zoo-design-studio
        nautilus
        nerd-fonts.fira-code
        noctalia-shell
        nwg-look
        pulseaudio
        qmk
        qmk-udev-rules
        spotify
        swayidle
        usbutils
        wezterm
        wl-clipboard
        wtype
        xwayland-satellite
      ];
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts.monospace = [ "FiraCode Nerd Font" ];
  };

  services = {
    # TODO fix noctalia clipboard preview + icons
    clipcat = {
      enable = true;
      enableZshIntegration = true;
      enableSystemdUnit = true;
    };
  };

  programs = {
    walker = {
      enable = true;
      runAsService = true;
      config = { }; # Use config TOML from this repo
    };

    # ghostty's nixpkgs package is Linux-only, so this whole module lives
    # here rather than in common.nix (macOS gets Ghostty via Homebrew cask).
    ghostty = {
      enable = true;
      enableFishIntegration = true;
      installBatSyntax = true;
      systemd.enable = true;
    };

    fish.shellAbbrs = {
      start = "sudo systemctl start";
      startu = "systemctl start --user";
      stop = "sudo systemctl stop";
      stopu = "systemctl stop --user";
      restart = "sudo systemctl restart";
      restartu = "systemctl restart --user";
    };
  };
}
