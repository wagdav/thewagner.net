{ pkgs ? (import ./nix/nixpkgs) }:

pkgs.mkShell {
  buildInputs = (import ./default.nix { inherit pkgs; }).requirements;
}
