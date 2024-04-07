# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./logiops.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rockboynton = {
    isNormalUser = true;
    description = "Rock Boynton";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    ];
    shell = pkgs.zsh;
  };

  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "rockboynton";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    neovim
    git
    google-chrome
    xclip
    logiops_0_2_3
  ];

  environment.pathsToLink = [
    "/share/zsh"
    "/share/nix-direnv"
  ];

  programs.zsh.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  nix.package = pkgs.nixFlakes;
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
