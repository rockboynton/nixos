# macOS-specific home-manager config. Kept minimal — GUI apps are managed
# via nix-darwin's declarative Homebrew at the host level, not here.
#
# home.username/home.homeDirectory are intentionally not set here: when
# home-manager is used as a nix-darwin module (not standalone), it derives
# both from `users.users.<name>`, so the consuming host file must declare
# `users.users.<name>.home = "/Users/<name>";` for the matching user.
{ pkgs, lib, config, ... }:

{
  imports = [
    ./common.nix
  ];

  # Link font packages into ~/Library/Fonts since fonts.fontconfig is
  # Linux-only; macOS discovers fonts from this directory directly.
  home.file."Library/Fonts/NixFonts" = {
    source = "${pkgs.symlinkJoin {
      name = "nix-fonts";
      paths = with pkgs; [ helvetica-neue-lt-std aileron fira roboto nerd-fonts.fira-code ];
    }}/share/fonts";
    recursive = true;
  };
}
