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
  };

  outputs = { self, nixpkgs, nixpkgs-stable, lanzaboote, ... } @ inputs:
    let
      inherit (self) outputs;
    in
    rec {
      inherit nixpkgs;
      inherit nixpkgs-stable;

      overlays = import ./overlays { inherit inputs; };

      nixosConfigurations."prometheus" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit outputs; };
        modules = [
          lanzaboote.nixosModules.lanzaboote
          ./configuration.nix
          {
            # environment.systemPackages = [ agenix.packages."x86_64-linux".default ]; # Weirdly ${system} is undefined here.
          }
        ];
      };

    };
}
