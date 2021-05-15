{
  description = "The contents of https://thewagner.net";

  inputs.nixpkgs.url = "nixpkgs/nixos-20.09";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem
    (system:
      let
        revision = "${self.lastModifiedDate}-${self.shortRev or "dirty"}";

        pkgs = nixpkgs.legacyPackages.${system};

        pythonEnv = pkgs.python3.withPackages (ps: with ps; [
          markdown
          pelican
          typogrify
        ]);

        buildSite = { relativeUrls ? false }: pkgs.stdenv.mkDerivation {
          name = "thewagner-net-${self.shortRev or "dirty"}";

          nativeBuildInputs = [ pythonEnv ];

          src = self;

          dontBuild = true;

          installPhase = ''
            pelican \
              --extra-settings \
                RELATIVE_URLS=${if relativeUrls then "True" else "False"}} \
              --fatal warnings \
              --settings publishconf.py \
              --output $out \
              ${./content}
          '';
        };

        buildImage =
          let
            port = "8000";
            htmlPages = buildSite { relativeUrls = true; };

          in
          pkgs.dockerTools.buildLayeredImage
            {
              name = "thewagner.net";
              tag = revision;
              contents = [ pkgs.darkhttpd htmlPages ];
              config = {
                Cmd = [
                  "darkhttpd"
                  "${htmlPages}"
                  "--port"
                  port
                ];
                ExposedPorts = {
                  "${port}/tcp" = { };
                };
              };
            };
      in
      {

        devShell = with pkgs; mkShell {
          buildInputs = [ pythonEnv skopeo ];
        };

        defaultPackage = self.packages.${system}.site;

        packages = {
          ociImage = buildImage;
          site = buildSite { };
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
              mdl ${./content}
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
