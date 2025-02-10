{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.05-darwin";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system: 
    let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = [
          pkgs.vscode
          pkgs.ocaml
          pkgs.dune-release
          pkgs.opam
          pkgs.ocamlPackages.ocaml-lsp
          pkgs.ocamlPackages.ocamlformat
        ];
        shellHook = ''
          eval $(opam env)
        '';
      };
    }
  );
}
