{ inputs }: { config, lib, pkgs, ... }:

{
  environment.systemPackages =
    [ pkgs.vim
    ];

  # Managed by determinate-nixd
  nix.enable = false;

  users.users.achuie = {
    name = "achuie";
    home = "/Users/achuie";
  };
  system.primaryUser = "achuie";
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.achuie = { pkgs, lib, ... }: {
      # Only cli programs
      home = {
        packages = with pkgs; [
          inputs.achuie-nvim.packages.${pkgs.system}.default
          tmux
        ];
        file = {
          ".zsh/.zshrc".source = ./dots/zsh/zshrc;
          ".zsh/prompts".source = ./dots/zsh/prompts;
          ".zsh/functions/prompt_achuie_setup".source = ./dots/zsh/prompts/achuie.zsh;
        };
        activation.weztermTerminfo = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          ${pkgs.ncurses}/bin/tic -x -o $HOME/.terminfo ${pkgs.wezterm.src}/termwiz/data/wezterm.terminfo
        '';
      };
      xdg.configFile = {
        "tmux/tmux.conf".source = ./dots/tmux/tmux.conf;
        "wezterm/wezterm.lua".source = ./dots/wezterm/wezterm.lua;
      };
      programs = {
        home-manager.enable = true;
        zsh = {
          enable = true;
          envExtra = builtins.readFile ./dots/zsh/zshenv;
        };
      };

      home.stateVersion = "25.05";
    };
  };

  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "achuie";
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };
    mutableTaps = false;
  };
  homebrew = {
    enable = true;
    taps = builtins.attrNames config.nix-homebrew.taps;
    casks = [
      "aldente"
      "rectangle"
      "wezterm"
    ];
  };

  # Set Git commit hash for darwin-version.
  system.configurationRevision = config.rev or config.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
