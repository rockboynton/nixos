{ pkgs }: {
  zoo-design-studio = pkgs.callPackage ./zoo-design-studio.nix { };
  echo-foo = pkgs.callPackage ./echo-foo.nix { };
}
