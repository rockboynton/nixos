{ pkgs, lib, config, ... }:

let
  nixosConfigDir = "${config.home.homeDirectory}/sources/nixos";
  localPackages = import ../pkgs { inherit pkgs; };
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
in
{
  imports = [
    ./common.nix
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
          "timeout 300 'noctalia msg session lock'"
          "timeout 600 'niri msg action power-off-monitors'"
          "resume 'niri msg action power-on-monitors'"
          "timeout 900 'systemctl suspend'"
          "before-sleep 'noctalia msg session lock'"
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
      enable = true;
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
      x11.enable = true;
      gtk.enable = true;
    };

    file.".config/ghostty/platform".source = mkOutOfStoreSymlink "${nixosConfigDir}/ghostty/linux";

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
        adwaita-icon-theme
        caprine
        discord
        element-desktop
        gimp
        google-chrome
        gtk3
        localPackages.kcl-language-server
        localPackages.zoo-cli
        localPackages.zoo-design-studio
        nautilus
        nerd-fonts.fira-code
        noctalia
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
        zoom-us
      ];
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts.monospace = [ "FiraCode Nerd Font" ];
  };

  services.udiskie.enable = true;

  programs = {
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
