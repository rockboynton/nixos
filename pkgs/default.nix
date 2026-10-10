{ pkgs }: {
  kcl-language-server = pkgs.callPackage ./kcl-language-server.nix { };
  zoo-cli = pkgs.callPackage ./zoo-cli.nix { };
  zoo-design-studio = pkgs.callPackage ./zoo-design-studio.nix { };
}
