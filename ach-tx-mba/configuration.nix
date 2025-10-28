{ config, lib, pkgs, inputs, ... }@args:

{
  environment.systemPackages =
    [ pkgs.vim
    ];

  # Managed by determinate-nixd
  nix.enable = false;

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "claude-code"
    "vscode"
    "vscode-extension-ms-vscode-remote-vscode-remote-extensionpack"
  ];

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
          args.iosevka

          inputs.achuie-nvim.packages.${pkgs.system}.default
          fd
          ripgrep
          skim
          tmux
          rustup

          claude-code
          azure-cli
        ];
        file = {
          ".zsh/.zshrc".source = ./dots/zsh/zshrc;
          ".zsh/prompts".source = ./dots/zsh/prompts;
          ".zsh/functions/prompt_achuie_setup".source = ./dots/zsh/prompts/achuie.zsh;

          ".claude/settings.json".source = ./dots/claude/settings.json;
          ".claude/anthropic_key.sh".source = pkgs.writeShellScript "anthropic_key.sh" ''
            cat ${config.age.secrets.anthropic-key.path}
          '';
        };
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
        vscode = {
          enable = true;
          profiles.default.extensions = with pkgs.vscode-extensions; [
            vscodevim.vim
            ms-vscode-remote.vscode-remote-extensionpack
          ];
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
      "rectangle"
      "middleclick"
      # For slack notifications
      "doll"

      "wezterm"
      "firefox"
      "slack"
      "obsidian"
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
