{ pkgs, lib, ... }:

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

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.blueman.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${lib.getExe pkgs.tuigreet} --time --cmd niri-session";
        user = "rockboynton";
      };
    };
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal
      xdg-desktop-portal-gnome
    ];
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  hardware.keyboard.qmk.enable = true;
  hardware.graphics.enable = true;
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
  };
  security = {
    polkit.enable = true;
    rtkit.enable = true;
    sudo.extraConfig = ''
      Defaults        timestamp_timeout=30
    '';
  };
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
  services.displayManager.autoLogin.user = "rockboynton";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
  systemd.packages = [ pkgs.kdePackages.polkit-kde-agent-1 ];

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
  programs.niri = {
    enable = true;
  };

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
