{ pkgs ? (import ./nix/nixpkgs) }:

pkgs.mkShell {
  buildInputs = (import ./release.nix { inherit pkgs; }).shell;
}
