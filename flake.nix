# flake.nix
#
# Copyright (C) 2024-today rydnr's pythoneda-shared-pythonlang-artf-def/banner
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
{
  description = "Nix flake for pythoneda-shared-pythonlang-artf/banner";
  inputs = rec {
    flake-utils = { url = "github:numtide/flake-utils/v1.0.0"; };
    nixpkgs = { url = "github:NixOS/nixpkgs/24.05"; };
    pythoneda-external-artf-flakeutils = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pythoneda-shared-nix-flake-shared.follows =
        "pythoneda-shared-nix-flake-shared";
      inputs.pythoneda-shared-pythonlang-banner.follows =
        "pythoneda-shared-pythonlang-banner";
      inputs.pythoneda-shared-pythonlang-domain.follows =
        "pythoneda-shared-pythonlang-domain";
      url = "github:pythoneda-external-artf-def/flakeutils/0.0.21";
    };
    pythoneda-external-artf-nixpkgs = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pythoneda-shared-nix-flake-shared.follows =
        "pythoneda-shared-nix-flake-shared";
      inputs.pythoneda-shared-pythonlang-banner.follows =
        "pythoneda-shared-pythonlang-banner";
      inputs.pythoneda-shared-pythonlang-domain.follows =
        "pythoneda-shared-pythonlang-domain";
      url = "github:pythoneda-external-artf-def/nixpkgs/0.0.19";
    };
    pythoneda-shared-nix-flake-shared = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pythoneda-shared-pythonlang-banner.follows =
        "pythoneda-shared-pythonlang-banner";
      inputs.pythoneda-shared-pythonlang-domain.follows =
        "pythoneda-shared-pythonlang-domain";
      url = "github:pythoneda-shared-nix-flake-def/shared/0.0.86";
    };
    pythoneda-shared-pythonlang-banner = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:pythoneda-shared-pythonlang-def/banner/0.0.74";
    };
    pythoneda-shared-pythonlang-domain = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pythoneda-shared-pythonlang-banner.follows =
        "pythoneda-shared-pythonlang-banner";
      url = "github:pythoneda-shared-pythonlang-def/domain/0.0.105";
    };
  };
  outputs = inputs:
    with inputs;
    let
      defaultSystems = flake-utils.lib.defaultSystems;
      supportedSystems = if builtins.elem "armv6l-linux" defaultSystems then
        defaultSystems
      else
        defaultSystems ++ [ "armv6l-linux" ];
    in flake-utils.lib.eachSystem supportedSystems (system:
      let
        org = "pythoneda-shared-pythonlang-artf";
        repo = "banner";
        version = "0.0.2";
        sha256 = "1g3wvxxqp7k8g9wqspas6qhvf76bjp8j3ihpx3hd52x4c2aj3wd5";
        pname = "${org}-${repo}";
        pythonpackage = "pythoneda.artifact.shared.banner";
        package = builtins.replaceStrings [ "." ] [ "/" ] pythonpackage;
        entrypoint = "banner_app";
        description = "Artifact for pythoneda-shared-pythonlang/banner";
        license = pkgs.lib.licenses.gpl3;
        homepage = "https://github.com/${org}/${repo}";
        maintainers = [ "rydnr <github@acm-sl.org>" ];
        archRole = "B";
        space = "D";
        layer = "D";
        nixpkgsVersion = builtins.readFile "${nixpkgs}/.version";
        nixpkgsRelease =
          builtins.replaceStrings [ "\n" ] [ "" ] "nixpkgs-${nixpkgsVersion}";
        shared = import "${pythoneda-shared-pythonlang-banner}/nix/shared.nix";
        pkgs = import nixpkgs { inherit system; };
        pythoneda-shared-pythonlang-artf-banner-for = { python
          , pythoneda-external-artf-flakeutils, pythoneda-external-artf-nixpkgs
          , pythoneda-shared-nix-flake-shared
          , pythoneda-shared-pythonlang-banner
          , pythoneda-shared-pythonlang-domain }:
          let
            pnameWithUnderscores =
              builtins.replaceStrings [ "-" ] [ "_" ] pname;
            pythonVersionParts = builtins.splitVersion python.version;
            pythonMajorVersion = builtins.head pythonVersionParts;
            pythonMajorMinorVersion =
              "${pythonMajorVersion}.${builtins.elemAt pythonVersionParts 1}";
            wheelName =
              "${pnameWithUnderscores}-${version}-py${pythonMajorVersion}-none-any.whl";
            banner_file = "${package}/banner_banner.py";
            banner_class = "bannerBanner";
          in python.pkgs.buildPythonPackage rec {
            inherit pname version;
            projectDir = ./.;
            pyprojectTomlTemplate = ./templates/pyproject.toml.template;
            pyprojectToml = pkgs.substituteAll {
              authors = builtins.concatStringsSep ","
                (map (item: ''"${item}"'') maintainers);
              desc = description;
              inherit homepage pname pythonMajorMinorVersion package
                version;
              pythonedaExternalArtfFlakeutils =
                pythoneda-external-artf-flakeutils.version;
              pythonedaExternalArtfNixpkgs =
                pythoneda-external-artf-nixpkgs.version;
              pythonedaSharedNixFlakeShared =
                pythoneda-shared-nix-flake-shared.version;
              pythonedaSharedPythonlangBanner =
                pythoneda-shared-pythonlang-banner.version;
              pythonedaSharedPythonlangDomain =
                pythoneda-shared-pythonlang-domain.version;
              src = pyprojectTomlTemplate;
            };
            bannerTemplateFile =
              "${pythoneda-shared-pythonlang-banner}/templates/banner.py.template";
            bannerTemplate = pkgs.substituteAll {
              project_name = pname;
              file_path = banner_file;
              inherit banner_class org repo;
              tag = version;
              pescio_space = space;
              arch_role = archRole;
              hexagonal_layer = layer;
              python_version = pythonMajorMinorVersion;
              nixpkgs_release = nixpkgsRelease;
              src = bannerTemplateFile;
            };

            entrypointTemplateFile =
              "${pythoneda-shared-pythonlang-banner}/templates/entrypoint.sh.template";
            entrypointTemplate = pkgs.substituteAll {
              arch_role = archRole;
              hexagonal_layer = layer;
              nixpkgs_release = nixpkgsRelease;
              inherit homepage maintainers org python repo version;
              pescio_space = space;
              python_version = pythonMajorMinorVersion;
              pythoneda_shared_pythonlang_banner =
                pythoneda-shared-pythonlang-banner;
              pythoneda_shared_pythonlang_domain =
                pythoneda-shared-pythonlang-domain;
              src = entrypointTemplateFile;
            };
            src = pkgs.fetchFromGitHub {
              owner = org;
              rev = version;
              inherit repo sha256;
            };

            format = "pyproject";

            nativeBuildInputs = with python.pkgs; [ pip poetry-core ];
            propagatedBuildInputs = with python.pkgs; [
              pythoneda-external-artf-flakeutils
              pythoneda-external-artf-nixpkgs
              pythoneda-shared-nix-flake-shared
              pythoneda-shared-pythonlang-banner
              pythoneda-shared-pythonlang-domain

            ];

            # pythonImportsCheck = [ pythonpackage ];

            unpackPhase = ''
              cp -r ${src} .
              sourceRoot=$(ls | grep -v env-vars)
              find $sourceRoot -type d -exec chmod 777 {} \;
              cp ${pyprojectToml} $sourceRoot/pyproject.toml
              cp ${bannerTemplate} $sourceRoot/${banner_file}
              cp ${entrypointTemplate} $sourceRoot/entrypoint.sh
            '';

            postPatch = ''
              substituteInPlace /build/$sourceRoot/entrypoint.sh \
                --replace "@SOURCE@" "$out/bin/${entrypoint}.sh" \
                --replace "@PYTHONPATH@" "$PYTHONPATH:$out/lib/python${pythonMajorMinorVersion}/site-packages" \
                --replace "@CUSTOM_CONTENT@" "" \
                --replace "@ENTRYPOINT@" "$out/lib/python${pythonMajorMinorVersion}/site-packages/${package}/application/${entrypoint}.py" \
                --replace "@BANNER@" "$out/bin/banner.sh"
            '';

            postInstall = ''
              pushd /build/$sourceRoot
              for f in $(find . -name '__init__.py'); do
                if [[ ! -e $out/lib/python${pythonMajorMinorVersion}/site-packages/$f ]]; then
                  cp $f $out/lib/python${pythonMajorMinorVersion}/site-packages/$f;
                fi
              done
              popd
              mkdir $out/dist $out/bin
              cp dist/${wheelName} $out/dist
              cp /build/$sourceRoot/entrypoint.sh $out/bin/${entrypoint}.sh
              chmod +x $out/bin/${entrypoint}.sh
              echo '#!/usr/bin/env sh' > $out/bin/banner.sh
              echo "export PYTHONPATH=$PYTHONPATH" >> $out/bin/banner.sh
              echo "${python}/bin/python $out/lib/python${pythonMajorMinorVersion}/site-packages/${banner_file} \$@" >> $out/bin/banner.sh
              chmod +x $out/bin/banner.sh
            '';

            meta = with pkgs.lib; {
              inherit description homepage license maintainers;
            };
          };
      in rec {
        apps = rec {
          default = pythoneda-shared-pythonlang-artf-banner-default;
          pythoneda-shared-pythonlang-artf-banner-default =
            pythoneda-shared-pythonlang-artf-banner-python312;
          pythoneda-shared-pythonlang-artf-banner-python38 = shared.app-for {
            package =
              self.packages.${system}.pythoneda-shared-pythonlang-artf-banner-python38;
            inherit entrypoint;
          };
          pythoneda-shared-pythonlang-artf-banner-python39 = shared.app-for {
            package =
              self.packages.${system}.pythoneda-shared-pythonlang-artf-banner-python39;
            inherit entrypoint;
          };
          pythoneda-shared-pythonlang-artf-banner-python310 = shared.app-for {
            package =
              self.packages.${system}.pythoneda-shared-pythonlang-artf-banner-python310;
            inherit entrypoint;
          };
          pythoneda-shared-pythonlang-artf-banner-python311 = shared.app-for {
            package =
              self.packages.${system}.pythoneda-shared-pythonlang-artf-banner-python311;
            inherit entrypoint;
          };
          pythoneda-shared-pythonlang-artf-banner-python312 = shared.app-for {
            package =
              self.packages.${system}.pythoneda-shared-pythonlang-artf-banner-python312;
            inherit entrypoint;
          };
        };
        defaultApp = apps.default;
        defaultPackage = packages.default;
        devShells = rec {
          default = pythoneda-shared-pythonlang-artf-banner-default;
          pythoneda-shared-pythonlang-artf-banner-default =
            pythoneda-shared-pythonlang-artf-banner-python312;
          pythoneda-shared-pythonlang-artf-banner-python38 =
            shared.devShell-for {
              banner = "${
                  pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python38
                }/bin/banner.sh";
              extra-namespaces = "";
              nixpkgs-release = nixpkgsRelease;
              package =
                packages.pythoneda-shared-pythonlang-artf-banner-python38;
              python = pkgs.python38;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python38;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python38;
              inherit archRole layer org pkgs repo space;
            };
          pythoneda-shared-pythonlang-artf-banner-python39 =
            shared.devShell-for {
              banner = "${
                  pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python39
                }/bin/banner.sh";
              extra-namespaces = "";
              nixpkgs-release = nixpkgsRelease;
              package =
                packages.pythoneda-shared-pythonlang-artf-banner-python39;
              python = pkgs.python39;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python39;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python39;
              inherit archRole layer org pkgs repo space;
            };
          pythoneda-shared-pythonlang-artf-banner-python310 =
            shared.devShell-for {
              banner = "${
                  pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python310
                }/bin/banner.sh";
              extra-namespaces = "";
              nixpkgs-release = nixpkgsRelease;
              package =
                packages.pythoneda-shared-pythonlang-artf-banner-python310;
              python = pkgs.python310;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python310;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python310;
              inherit archRole layer org pkgs repo space;
            };
          pythoneda-shared-pythonlang-artf-banner-python311 =
            shared.devShell-for {
              banner = "${
                  pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python311
                }/bin/banner.sh";
              extra-namespaces = "";
              nixpkgs-release = nixpkgsRelease;
              package =
                packages.pythoneda-shared-pythonlang-artf-banner-python311;
              python = pkgs.python311;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python311;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python311;
              inherit archRole layer org pkgs repo space;
            };
          pythoneda-shared-pythonlang-artf-banner-python312 =
            shared.devShell-for {
              banner = "${
                  pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python312
                }/bin/banner.sh";
              extra-namespaces = "";
              nixpkgs-release = nixpkgsRelease;
              package =
                packages.pythoneda-shared-pythonlang-artf-banner-python312;
              python = pkgs.python312;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python312;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python312;
              inherit archRole layer org pkgs repo space;
            };
        };
        packages = rec {
          default = pythoneda-shared-pythonlang-artf-banner-default;
          pythoneda-shared-pythonlang-artf-banner-default =
            pythoneda-shared-pythonlang-artf-banner-python312;
          pythoneda-shared-pythonlang-artf-banner-python38 =
            pythoneda-shared-pythonlang-artf-banner-for {
              python = pkgs.python38;
              pythoneda-external-artf-flakeutils =
                pythoneda-external-artf-flakeutils.packages.${system}.pythoneda-external-artf-flakeutils-python38;
              pythoneda-external-artf-nixpkgs =
                pythoneda-external-artf-nixpkgs.packages.${system}.pythoneda-external-artf-nixpkgs-python38;
              pythoneda-shared-nix-flake-shared =
                pythoneda-shared-nix-flake-shared.packages.${system}.pythoneda-shared-nix-flake-shared-python38;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python38;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python38;
            };
          pythoneda-shared-pythonlang-artf-banner-python39 =
            pythoneda-shared-pythonlang-artf-banner-for {
              python = pkgs.python39;
              pythoneda-external-artf-flakeutils =
                pythoneda-external-artf-flakeutils.packages.${system}.pythoneda-external-artf-flakeutils-python39;
              pythoneda-external-artf-nixpkgs =
                pythoneda-external-artf-nixpkgs.packages.${system}.pythoneda-external-artf-nixpkgs-python39;
              pythoneda-shared-nix-flake-shared =
                pythoneda-shared-nix-flake-shared.packages.${system}.pythoneda-shared-nix-flake-shared-python39;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python39;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python39;
            };
          pythoneda-shared-pythonlang-artf-banner-python310 =
            pythoneda-shared-pythonlang-artf-banner-for {
              python = pkgs.python310;
              pythoneda-external-artf-flakeutils =
                pythoneda-external-artf-flakeutils.packages.${system}.pythoneda-external-artf-flakeutils-python310;
              pythoneda-external-artf-nixpkgs =
                pythoneda-external-artf-nixpkgs.packages.${system}.pythoneda-external-artf-nixpkgs-python310;
              pythoneda-shared-nix-flake-shared =
                pythoneda-shared-nix-flake-shared.packages.${system}.pythoneda-shared-nix-flake-shared-python310;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python310;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python310;
            };
          pythoneda-shared-pythonlang-artf-banner-python311 =
            pythoneda-shared-pythonlang-artf-banner-for {
              python = pkgs.python311;
              pythoneda-external-artf-flakeutils =
                pythoneda-external-artf-flakeutils.packages.${system}.pythoneda-external-artf-flakeutils-python311;
              pythoneda-external-artf-nixpkgs =
                pythoneda-external-artf-nixpkgs.packages.${system}.pythoneda-external-artf-nixpkgs-python311;
              pythoneda-shared-nix-flake-shared =
                pythoneda-shared-nix-flake-shared.packages.${system}.pythoneda-shared-nix-flake-shared-python311;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python311;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python311;
            };
          pythoneda-shared-pythonlang-artf-banner-python312 =
            pythoneda-shared-pythonlang-artf-banner-for {
              python = pkgs.python312;
              pythoneda-external-artf-flakeutils =
                pythoneda-external-artf-flakeutils.packages.${system}.pythoneda-external-artf-flakeutils-python312;
              pythoneda-external-artf-nixpkgs =
                pythoneda-external-artf-nixpkgs.packages.${system}.pythoneda-external-artf-nixpkgs-python312;
              pythoneda-shared-nix-flake-shared =
                pythoneda-shared-nix-flake-shared.packages.${system}.pythoneda-shared-nix-flake-shared-python312;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python312;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python312;
            };
        };
      });
}
