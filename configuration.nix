{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./logiops.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.blueman.enable = true;

  services.logiops = {
    enable = true;

    settings = {
      devices = [{
        name = "Wireless Mouse MX Master 3";

        smartshift = {
          on = true;
          threshold = 30;
          torque = 50;
        };

        hiresscroll = {
          hires = true;
          invert = false;
          target = false;
        };

        dpi = 1000;

        buttons = [
          {
            cid = "0x53";
            action = {
              type = "Keypress";
              keys = [ "KEY_FORWARD" ];
            };
          }
          {
            cid = "0x56";
            action = {
              type = "Keypress";
              keys = [ "KEY_BACK" ];
            };
          }
          {
            cid = "0xc3";
            action = {
              type = "Gestures";
              gestures = [
                {
                  direction = "Left";
                  action = {
                    type = "Keypress";
                    keys = [ "KEY_LEFTCTRL" "KEY_C" ];
                  };
                }
                {
                  direction = "Right";
                  action = {
                    type = "Keypress";
                    keys = [ "KEY_LEFTCTRL" "KEY_V" ];
                  };
                }
                {
                  direction = "None";
                  action = {
                    type = "Keypress";
                    keys = [ "KEY_ENTER" ];
                  };
                }
              ];
            };
          }
        ];
      }];
    };
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  hardware.keyboard.qmk.enable = true;
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
  };
  security.rtkit.enable = true;
  security.sudo.extraConfig = ''
    Defaults        timestamp_timeout=30
  '';
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  powerManagement.cpuFreqGovernor = "performance";

  users.users.rockboynton = {
    isNormalUser = true;
    description = "Rock Boynton";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = [ ];
    shell = pkgs.fish;
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "rockboynton";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    helix
    git
    xclip
  ];

  environment.pathsToLink = [
    "/share/fish"
    "/share/nix-direnv"
  ];

  programs.fish.enable = true;

  # don't change this
  system.stateVersion = "23.05"; # Did you read the comment?

  nix.package = pkgs.nixVersions.stable;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [
      "root"
      "rockboynton"
      "@wheel"
    ];
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-substituters = [
      "https://hydra.nixos.org/"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
    ];
  };
}
