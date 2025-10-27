{
  description = "Configs for darwin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # For ragenix, see https://github.com/yaxitech/ragenix/issues/159
    nixpkgs-2411.url = "github:nixos/nixpkgs/nixos-24.11";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    achuie-nvim = {
      url = "github:achuie/config.nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs-2411";
    };
  };

  outputs = { self, nix-darwin, nixpkgs, ... }@inputs:
    let
      iosevka-wl =
        let
          version = "v0.2.0";
        in
        nixpkgs.legacyPackages.aarch64-darwin.fetchzip {
          inherit version;
          pname = "iosevka-wl";
          url = "https://github.com/achuie/iosevka-wl/releases/download/${version}/iosevka-wl-artifact.zip";
          hash = "sha256-TeOP1D8J9MrcvCLQx9D2gjokZaALRim+NVUHUOGYFAA=";
          stripRoot = false;
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#ach-tx-mba
      darwinConfigurations."ach-tx-mba" = nix-darwin.lib.darwinSystem {
        specialArgs = {
          inherit inputs;
          iosevka = iosevka-wl;
        };
        modules = [
          ./ach-tx-mba/configuration.nix
          inputs.nix-homebrew.darwinModules.nix-homebrew
          inputs.home-manager.darwinModules.default

          inputs.agenix.darwinModules.default
          {
            age = {
              identityPaths = [ "/Users/achuie/.ssh/id_ed25519" ];
              secrets.anthropic-key = {
                file = ./secrets/anthropic-key.age;
                mode = "770";
                owner = "achuie";
                group = "achuie";
              };
            };
          }
          { environment.systemPackages = [ inputs.agenix.packages.aarch64-darwin.default ]; }
        ];
      };
    };
}
