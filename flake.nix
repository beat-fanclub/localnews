{
  description = "Local news webservice.";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
  flake-utils.lib.eachDefaultSystem ( system:
  let
    pkgs = nixpkgs.legacyPackages.${system};
    ruby = pkgs.ruby_2_7;
    bundler = pkgs.bundler.override { inherit ruby; };
    bundix = pkgs.bundix.override { inherit bundler; };
    gems = pkgs.bundlerEnv {
      name = "localnews";
      inherit ruby;
      gemdir = ./.;
    };
    start-db = pkgs.writeScriptBin "start-db" ''
      #!${pkgs.stdenv.shell}
      export PGHOST=/tmp/postgres/localnews
      export PGDATA=$PGHOST/data
      export PGDATABASE=postgres
      export PGLOG=$PGHOST/postgres.log

      mkdir -p $PGHOST

      if [ ! -d $PGDATA ]; then
        ${pkgs.postgresql}/bin/initdb --auth=trust --no-locale --encoding=UTF8
      fi

      if ! ${pkgs.postgresql}/bin/pg_ctl status
      then
        ${pkgs.postgresql}/bin/pg_ctl start -l $PGLOG -o "--unix_socket_directories='$PGHOST'"
      fi
    '';
  in
  rec {
    packages = {
      devShell.${system} = pkgs.mkShell {
        buildInputs = [
          gems
          ruby
          pkgs.yarn
          pkgs.yarn2nix
          pkgs.nodejs
          bundix
          packages.frontend
          start-db
          pkgs.postgresql
        ];

        shellHook = ''
          . ${start-db}/bin/start-db
        '';
      };

      frontend = pkgs.mkYarnPackage {
        name = "localnews-frontend";
        src = ./.;
        yarnLock = ./yarn.lock;
        yarnNix = ./yarn.nix;
        packageJSON = ./package.json;
      };
    };
  }
  );
}
