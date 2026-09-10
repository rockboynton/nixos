{
  description = "My NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    helix = {
      url = "github:rockboynton/helix?ref=patchy";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
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
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    elephant = {
      url = "github:abenz1267/elephant";
    };
    walker = {
      url = "github:abenz1267/walker";
      inputs.elephant.follows = "elephant";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, treefmt-nix, ... }:
    let
      system = "x86_64-linux";

      supportedSystems = [ "x86_64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      mkFormatter = system: treefmt-nix.lib.mkWrapper nixpkgs.legacyPackages.${system} {
        programs = {
          nixpkgs-fmt.enable = true; # nix
          # kdlfmt.enable = true; # KDL, add back when more options like preserving newlines are added
          taplo.enable = true; # taplo
          mdformat.enable = true; # Markdown
          stylua.enable = true; # Lua
        };
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./hosts/nixos

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.rockboynton.imports = [ ./home/linux.nix ];
              extraSpecialArgs = { inherit inputs; };
            };
          }
        ];
      };

      # This flake defines no `darwinConfigurations` itself — consumers (this repo later, or a separate private flake
      # with host-specific config) compose these modules with `nix-darwin.lib.darwinSystem`, supplying their own
      # hostname, `primaryUser`, and `homebrew.taps/casks/brews`.
      #
      # These modules read `inputs` from `specialArgs`. If a consumer passes its own `inputs` here and happens to
      # declare a same-named input (e.g. its own unrelated `helix`), that name will silently shadow this flake's pin.
      # Pass `inputs // self.inputs` (with this flake's `self` on the right so it wins on overlap) rather than the
      # consumer's raw `inputs`.
      darwinModules.default = ./hosts/darwin;
      homeManagerModules = {
        common = ./home/common.nix;
        linux = ./home/linux.nix;
        darwin = ./home/darwin.nix;
      };

      formatter = forAllSystems mkFormatter;

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = [
              self.formatter.${system}
            ] ++ (with pkgs; [
              taplo
              harper
              mdformat
              rumdl
            ]);
          };
        });
    };
}

