{
  description = "Minimal reproduction of pytensor setuptools runtime dependency issue";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells = {
          default = pkgs.mkShell {
            packages = with pkgs; [
              (python3.withPackages (ps: with ps; [
                pymc
                ipython
              ]))
            ];
          };

          pytensor-only = pkgs.mkShell {
            packages = with pkgs; [
              (python3.withPackages (ps: with ps; [
                pytensor
              ]))
            ];
          };

          # Test fix with propagatedBuildInputs
          fix-propagated = pkgs.mkShell {
            packages = with pkgs; [
              (python3.withPackages (ps: with ps; [
                (pytensor.overridePythonAttrs (old: {
                  propagatedBuildInputs = (old.propagatedBuildInputs or []) ++ [ ps.setuptools ];
                  doCheck = false;
                }))
              ]))
            ];
          };

          # Test fix with dependencies
          fix-dependencies = pkgs.mkShell {
            packages = with pkgs; [
              (python3.withPackages (ps: with ps; [
                (pytensor.overridePythonAttrs (old: {
                  dependencies = (old.dependencies or []) ++ [ ps.setuptools ];
                  doCheck = false;
                }))
              ]))
            ];
          };
        };
      }
    );
}
