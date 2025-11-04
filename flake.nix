{
  description = "My NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    helix = {
      url = "github:rockboynton/helix?ref=patchy";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    jj = {
      url = "github:jj-vcs/jj";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yazi = {
      url = "github:sxyazi/yazi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Zoo Design Studio
    modeling-app = {
      url = "github:KittyCAD/modeling-app";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zoo-cli = {
      url = "github:kittycad/cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    omarchy-nix = {
      url = "github:henrysipp/omarchy-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, stylix, tinted-theming, omarchy-nix, ... }:
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
          omarchy-nix.nixosModules.default

          home-manager.nixosModules.home-manager
          {
            omarchy = {
              full_name = "Rock Boynton";
              email_address = "rock.boynton@yahoo.com";
              theme = "gruvbox";
            };

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.rockboynton = import ./home.nix;
              extraSpecialArgs = { inherit inputs; };
              sharedModules = [{ }];
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
        packages = [ ];
      };
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
    };
}

