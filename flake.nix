{
  description = "Configs for darwin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
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
  };

  outputs = { self, nix-darwin, nixpkgs, ... }@inputs:
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#simple
      darwinConfigurations."ach-tx-mba" = nix-darwin.lib.darwinSystem {
        modules = [
          (import ./ach-tx-mba/configuration.nix { inherit inputs; })
          inputs.nix-homebrew.darwinModules.nix-homebrew
          inputs.home-manager.darwinModules.default
        ];
      };
    };
}
