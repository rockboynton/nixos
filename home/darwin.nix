# GUI apps are managed via nix-darwin's declarative Homebrew at the host
# level, not here.
#
# home.username/home.homeDirectory are intentionally not set here: when
# home-manager is used as a nix-darwin module (not standalone), it derives
# both from `users.users.<name>`, so the consuming host file must declare
# `users.users.<name>.home = "/Users/<name>";` for the matching user.
{ pkgs, config, ... }:

let
  nixosConfigDir = "${config.home.homeDirectory}/sources/nixos";
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
in
{
  imports = [
    ./common.nix
  ];

  # fonts.fontconfig is Linux-only; macOS discovers fonts from this
  # directory directly.
  home.file."Library/Fonts/NixFonts" = {
    source = "${pkgs.symlinkJoin {
      name = "nix-fonts";
      paths = with pkgs; [ helvetica-neue-lt-std aileron fira roboto nerd-fonts.fira-code ];
    }}/share/fonts";
    recursive = true;
  };

  home.file.".hammerspoon/init.lua".source = mkOutOfStoreSymlink "${nixosConfigDir}/hammerspoon/init.lua";
}
