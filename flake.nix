{
  description = "The contents of https://thewagner.net";

  inputs.nixpkgs.url = "nixpkgs/nixos-20.09";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem
    (system:
      let
        revision = "${self.lastModifiedDate}-${self.shortRev or "dirty"}";

        system = "x86_64-linux";

        pkgs = nixpkgs.legacyPackages.${system};

        pythonEnv = pkgs.python3.withPackages (ps: with ps; [
          markdown
          pelican
          pygal
          typogrify
        ]);

        htmlPages = pkgs.runCommand "pelican"
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


      in
      rec {

        defaultPackage = htmlPages;

        packages = {
          ociImage =
            let
              port = 8000;

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

        checks = {

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
      });
}
