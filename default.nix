{ pkgs ? (import ./nix/nixpkgs) }:

let

pythonEnv = pkgs.python3.withPackages (ps: with ps; [
  markdown
  pelican
  pygal
  typogrify
]);

in

{
  shell = with pkgs; [
    ghp-import
    git
  ] ++ [ pythonEnv ];

  lint = pkgs.runCommand "mdl"
    {
      buildInputs = with pkgs; [ mdl ];
      preferLocalBuild = true;
    }
    ''
       mkdir $out
       mdl ${./content}/2020*
    '';

  publish = pkgs.runCommand "pelican"
    {
      preferLocalBuild = true;
      nativeBuildInputs = [ pythonEnv ];
    }
    ''
      ln --symbolic ${./theme} theme
      ln --symbolic ${./plugins} plugins
      ln --symbolic ${./pelicanconf.py} pelicanconf.py
      ln --symbolic ${./publishconf.py} publishconf.py

      pelican \
        --settings publishconf.py \
        --output $out \
        ${./content}
    '';
}
