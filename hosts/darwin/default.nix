# Generic, hostname-less nix-darwin module shared by any Mac (personal or
# work). Consumers import this and supply their own hostname, primaryUser,
# homebrew.taps/casks/brews, and system.stateVersion (nix-darwin requires
# this to be set explicitly once, at install time, by whoever brings up
# that specific machine — see `darwin-rebuild changelog`) via their own
# host file.
{ pkgs, ... }:

{
  security.pam.services.sudo_local.touchIdAuth = true;

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
  };

  # Nix itself is expected to be installed and managed externally (e.g. the
  # Determinate Nix installer, or a work-specific installer) rather than by
  # nix-darwin. Those installers actively regenerate /etc/nix/nix.conf and
  # run their own daemon via launchd; letting nix-darwin also try to manage
  # nix.conf/the daemon fights them for the same files. Any extra
  # substituters/settings you need belong in nix.custom.conf (or whatever
  # your installer's own override mechanism is), not here.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
  ];

  programs.fish.enable = true;
  # nix-darwin's programs.fish (unlike NixOS's) doesn't register fish in
  # /etc/shells on its own; without this, `chsh -s ...` rejects it.
  environment.shells = [ pkgs.fish ];

  # sudo's secure_path doesn't include this by default, so `sudo darwin-rebuild`
  # (and other system tools) can't be found by bare name under sudo otherwise.
  security.sudo.extraConfig = ''
    Defaults secure_path+="/run/current-system/sw/bin"
  '';
}
