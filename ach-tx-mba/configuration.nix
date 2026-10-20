{ config, lib, pkgs, inputs, ... }@args:

{
  environment.systemPackages =
    [ pkgs.vim
    ];

  # Managed by determinate-nixd
  nix.enable = false;

  nixpkgs.overlays = [ (import ../overlays/azure-cli-deployments-pin.nix) ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "claude-code"
    "vscode"
    "vscode-extension-ms-vscode-remote-vscode-remote-extensionpack"
  ];

  programs.zsh = {
    # achuie's zshrc runs its own (cached) compinit; a second global one with a different fpath
    # invalidates the dump and rebuilds it on every shell start.
    enableGlobalCompInit = false;
    enableBashCompletion = false;
    # Keep completion for root and other users without their own zshrc.
    interactiveShellInit = ''
      if [[ ! -e ''${ZDOTDIR:-$HOME}/.zshrc ]]; then
        autoload -U compinit && compinit
        autoload -U bashcompinit && bashcompinit
      fi
    '';
  };

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
          picocom
          git-lfs
          gh

          claude-code
          azure-cli
          azure-storage-azcopy
          bicep
          azure-functions-core-tools
          ansible
          ansible-lint
        ];
        file = {
          ".zsh/.zshrc".source = ./dots/zsh/zshrc;
          ".zsh/prompts".source = ./dots/zsh/prompts;
          ".zsh/functions/prompt_achuie_setup".source = ./dots/zsh/prompts/achuie.zsh;

          ".wezterm.lua".source = ./dots/wezterm/wezterm.lua;

          "scripts/gwt".source = ./scripts/gwt;

          ".claude/settings.json".source = ./dots/claude/settings.json;
          ".claude/statusline.sh".source = ./dots/claude/statusline.sh;
          ".claude/anthropic_key.sh".source = pkgs.writeShellScript "anthropic_key.sh" ''
            cat ${config.age.secrets.anthropic-key.path}
          '';
        };
      };
      # zshrc only re-checks the completion dump daily; drop it so new completions show up after a switch.
      home.activation.clearZcompdump = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run rm -f "$HOME/.zsh/.zcompdump"
      '';
      xdg.configFile = {
        "tmux/tmux.conf".source = ./dots/tmux/tmux.conf;
        # "wezterm/wezterm.lua".source = ./dots/wezterm/wezterm.lua;
        "ghostty/config".source = ./dots/ghostty/config;
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
      "ghostty"
      "firefox"
      "google-chrome"
      "slack"
      "obsidian"
    ];
  };

  services.tailscale.enable = true;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = config.rev or config.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
