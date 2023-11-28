{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.05";

    # agenix.url = "github:ryantm/agenix";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    NixOS-WSL = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, lanzaboote, NixOS-WSL, ... } @ inputs:
    let
      inherit (self) outputs;
    in
    rec {
      inherit nixpkgs;
      inherit nixpkgs-stable;

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;

      overlays.default = final: prev: (import ./overlays inputs) final prev;

      nixosConfigurations."prometheus" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit outputs; };
        modules = [
          lanzaboote.nixosModules.lanzaboote
          ./machines/all
          ./machines/prometheus/configuration.nix
          {
            # environment.systemPackages = [ agenix.packages."x86_64-linux".default ]; # Weirdly ${system} is undefined here.
          }
        ];
      };

      nixosConfigurations."gaia" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit outputs; };
        modules = [
          NixOS-WSL.nixosModules.wsl
          ./machines/all
          ./machines/wsl/configuration.nix
        ];
      };
    };
}

