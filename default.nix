{ pkgs ? (import ./nix/nixpkgs) }:

let

pythonEnv = pkgs.python37.withPackages (ps: with ps; [
  markdown
  pelican
  pygal
  typogrify
]);

in

{
  requirements = with pkgs; [
    ghp-import
    git
  ] ++ [ pythonEnv ];

  publish = pkgs.runCommand "pelican" {} ''
    ln --symbolic ${./theme} theme
    ln --symbolic ${./plugins} plugins
    ln --symbolic ${./pelicanconf.py} pelicanconf.py
    ${pythonEnv}/bin/pelican \
      ${./content} \
      --settings ${./publishconf.py} \
      --output $out
  '';
}
