{
  description = "The contents of https://thewagner.net";

  inputs.nixpkgs.url = "nixpkgs/nixos-20.09";

  outputs = { self, nixpkgs }:
    let
      revision = "${self.lastModifiedDate}-${self.shortRev or "dirty"}";

      system = "x86_64-linux";

      pkgs = import nixpkgs { inherit system; };

      pythonEnv = pkgs.python3.withPackages (ps: with ps; [
        markdown
        pelican
        pygal
        typogrify
      ]);

    in
    rec {

      defaultPackage."${system}" = packages."${system}".thewagner-net;

      packages."${system}" = {
        thewagner-net = pkgs.runCommand "pelican"
          {
            preferLocalBuild = true;
            buildInputs = [ pythonEnv ];
          }
          ''
            ln --symbolic ${./theme} theme
            ln --symbolic ${./plugins} plugins
            ln --symbolic ${./pelicanconf.py} pelicanconf.py
            ln --symbolic ${./publishconf.py} publishconf.py

            pelican \
              --fatal warnings \
              --settings publishconf.py \
              --output $out \
              ${./content}
          '';

        ociImage =
          let
            port = 8000;

            htmlPages = self.packages."${system}".thewagner-net;

          in
          pkgs.dockerTools.buildLayeredImage
            {
              name = "thewagner.net";
              tag = revision;
              contents = [ pkgs.python3Minimal htmlPages ];
              config = {
                Cmd = [
                  "${pkgs.python3Minimal}/bin/python"
                  "-m"
                  "http.server"
                  (builtins.toString port)
                  "--directory"
                  "${htmlPages}"
                ];
                Expose = [ port ];
              };
            };

      };

      checks."${system}" = {

        build = self.defaultPackage."${system}";

        buildImage = self.packages."${system}".ociImage;

        shellcheck = pkgs.runCommand "shellcheck"
          {
            buildInputs = with pkgs; [ shellcheck ];
          }
          ''
            mkdir $out
            shellcheck --shell bash ${./scripts}/*
          '';

        markdownlint = pkgs.runCommand "mdl"
          {
            buildInputs = with pkgs; [ mdl ];
          }
          ''
            mkdir $out
            mdl ${./README.md}
            mdl ${./content}/2020*
          '';

        yamllint = pkgs.runCommand "yamllint"
          {
            buildInputs = with pkgs; [ yamllint ];
          }
          ''
            mkdir $out
            yamllint --strict ${./.github/workflows}
          '';
      };
    };
}
