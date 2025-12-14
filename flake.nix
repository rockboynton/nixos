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
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      # Don't use this flake's nixpkgs since we want to use the Niri flake's cached Niri
      # inputs.nixpkgs.follows = "nixpkgs";
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
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.rockboynton = import ./home.nix;
              extraSpecialArgs = { inherit inputs; };
              sharedModules = [{ }];
            };
          }
        ];
      };

      formatter.${system} = treefmt-nix.lib.mkWrapper pkgs {
        programs = {
          nixpkgs-fmt.enable = true; # nix
          stylua = {
            # Lua
            enable = true;
            settings = {
              indent_type = "Spaces";
              quote_style = "AutoPreferSingle";
            };
          };
          # kdlfmt.enable = true; # KDL, add back when more options like preserving newlines are added
          taplo.enable = true; # taplo
          mdformat.enable = true; # Markdown
        };
      };

      devShells.${system}.default =
        let
          pkgsFromNix = with pkgs; [
            stylua
            taplo
            harper
            marksman
            mdformat
          ];
        in
        pkgs.mkShell {
          packages = [
            self.formatter.${system}
          ] ++ pkgsFromNix;
        };
    };
}

