{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";

    agenix.url = "github:ryantm/agenix";

    NixOS-WSL = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, agenix, NixOS-WSL, ... } @ inputs:
    let
      inherit (self) outputs;
    in
    rec {
      inherit nixpkgs;
      inherit nixpkgs-stable;

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;

      overlays.default = final: prev: (import ./overlays inputs) final prev;

      # WSL
      nixosConfigurations."morpheus" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit outputs; };
        modules = [
          NixOS-WSL.nixosModules.wsl
          ./machines/all
          ./machines/wsl/configuration.nix
        ];
      };

      # NUC
      nixosConfigurations."nuc" = nixpkgs-stable.lib.nixosSystem rec {
        system = "x86_64-linux";

        specialArgs = { inherit outputs; };
        modules = [
          ./machines/all
          ./machines/nuc/configuration.nix
          ./services/grafana.nix # Enable grafana and Prometheus service
        ];
      };
    };
}


