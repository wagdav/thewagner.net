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

  lint-markdown = pkgs.runCommand "mdl"
    {
      buildInputs = with pkgs; [ mdl ];
    }
    ''
       mkdir $out
       mdl ${./content}/2020*
    '';

  lint-scripts = pkgs.runCommand "shellcheck"
    {
      buildInputs = with pkgs; [ shellcheck ];
    }
    ''
      mkdir $out
      shellcheck --shell bash ${./scripts}/*
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
