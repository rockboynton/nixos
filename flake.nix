{
  description = "My NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tinted-theming = {
      url = "github:tinted-theming/schemes";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, stylix, tinted-theming }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.rockboynton = import ./home.nix;
              extraSpecialArgs = { inherit inputs; };
              sharedModules = [{
                stylix.targets = {
                  helix.enable = false;
                  fish.enable = false;
                };
              }];
            };
          }

          stylix.nixosModules.stylix
          {
            stylix = {
              image = ./gruvbox.png;
              polarity = "dark";
              base16Scheme = "${tinted-theming}/base16/gruvbox-dark-medium.yaml";
              opacity.terminal = 0.8;
              fonts.monospace = {
                package = nixpkgs.legacyPackages.${system}.fira-code-nerdfont;
                name = "FiraCode Nerd Font";
              };
            };
          }
        ];
      };
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          nil
          nixpkgs-fmt
        ];
      };
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
    };
}

