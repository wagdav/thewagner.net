{
  description = "The contents of https://thewagner.net";

  inputs.nixpkgs.url = "nixpkgs/nixos-24.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-compat = {
    url = github:edolstra/flake-compat;
    flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, flake-compat }: flake-utils.lib.eachDefaultSystem
    (system:
      let
        revision = "${self.shortRev or "dirty"}";

        pkgs = nixpkgs.legacyPackages.${system};

        pythonEnv = pkgs.python3.withPackages (ps: with ps; [
          markdown
          pelican
          typogrify
        ]);

        buildSite = { relativeUrls ? false }: pkgs.stdenv.mkDerivation {
          name = "thewagner-net-${self.shortRev or "dirty"}";

          nativeBuildInputs = [ pythonEnv ];

          src = builtins.path {
            filter = path: type: type != "directory" || baseNameOf path != "archive";
            path = ./.;
            name = "src";
          };

          dontBuild = true;

          installPhase = ''
            pelican \
              --extra-settings \
                RELATIVE_URLS=${if relativeUrls then "true" else "false"} \
                REVISION='"${revision}"' \
              --fatal warnings \
              --settings publishconf.py \
              --output $out \
              ./content
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
              config = {
                Cmd = [
                  "${pkgs.darkhttpd}/bin/darkhttpd"
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

        devShells.default = with pkgs; mkShell {
          buildInputs = [
            pythonEnv
            skopeo
            (aspellWithDicts (ds: [ ds.en ]))
          ];
        };

        packages = {
          ociImage = buildImage;
          default = buildSite { };
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
