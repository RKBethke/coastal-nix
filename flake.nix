{
  description = "Tidal Cycles playground. Powered by Nix.";
  # Tidal Cycles Playground
  # Usage:
  #   `superdirt-start [superdirt-with-samples.sc]`
  #   `tidal-vim <file_name>.tidal`
  #   <C-e> to begin plugin and evaluate line

  inputs = {
    nixpkgs.url = "nixpkgs";
    tidal.url = "github:mitchmindtree/tidalcycles.nix";
  };

  outputs = {
    self,
    nixpkgs,
    tidal,
  }: let
    forAllSystems = inFunc:
      nixpkgs.lib.genAttrs [
        "x86_64-linux"
      ]
      (system:
        inFunc (
          import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [];
          }
        ));
  in rec {
    formatter = forAllSystems (pkgs: pkgs.alejandra);

    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {
        packages = [
          pkgs.pulsar
          pkgs.libsForQt5.qt5.qtwayland
          (pkgs.haskellPackages.ghcWithPackages (a: [a.tidal]))
          ((pkgs.vim_configurable.override {}).customize {
            name = "tidal-vim";
            vimrcConfig.plug.plugins = with pkgs.vimPlugins; [
              vim-nix
              sonokai
              YouCompleteMe
              tidal.packages.x86_64-linux.vim-tidal
            ];
            vimrcConfig.customRC = ''
              let maplocalleader=" "

              set nocompatible
              set backspace=indent,eol,start
              set foldmethod=marker
              set number relativenumber
              set nu rnu

              syntax on
              set background=dark
              colorscheme sonokai
            '';
          })
        ];
        inputsFrom = [tidal.devShells.x86_64-linux.default];

        # Change the prompt to show that you are in a devShell
        shellHook = "export PS1='\\e[1;34mdev > \\e[0m'";
      };
    });
  };
}
