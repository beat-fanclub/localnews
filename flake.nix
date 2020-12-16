{
  description = "Local news webservice.";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (
      system:
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

          postgresql = (pkgs.postgresql_11.withPackages (ps: [ ps.postgis ]));
          start-db = pkgs.writeScriptBin "start-db" ''
            #!${pkgs.stdenv.shell}
            export PGHOST=/tmp/postgres/localnews
            export PGDATA=$PGHOST/data
            export PGDATABASE=postgres
            export PGLOG=$PGHOST/postgres.log

            mkdir -p $PGHOST

            if [ ! -d $PGDATA ]; then
              ${postgresql}/bin/initdb --auth=trust --no-locale --encoding=UTF8
            fi

            if ! ${postgresql}/bin/pg_ctl status
            then
              ${postgresql}/bin/pg_ctl start -l $PGLOG -o "--unix_socket_directories='$PGHOST'"
            fi

            redis-server &
          '';

          redis = pkgs.redis;

          name = "localnews";
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
                  # packages.frontend
                  start-db
                  postgresql
                  redis
                ];

                FACEBOOK_APP_ID = "473851313601205";
                FACEBOOK_APP_SECRET = "f9ddaa7eef8598ab88ca9806a672c00b";

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
              localnewsGems = gems;

              backend = pkgs.mkDerivation {
                name = "${name}-backend";
                buildInputs = [ gems pkgs.coreutils ];
                nativeBuildInputs = [ pkgs.makeWrapper packages.frontend ];
                src = ./.;
                outputs = [ "out" "public" ];

                RAILS_ENV = "production";
                BUNDLE_WITHOUT = "test:development";

                buildPhase = ''
                  echo "Symlinking node_modules"
                  ln -s ${packages.frontend}/libexec/${name}/node_modules node_modules
                  export SECRET_KEY_BASE="$(rails secret)"
                  echo Webpacker
                  rails webpacker:compile
                  echo Assets
                  rails assets:precompile
                  rm node_modules
                  rm public/packs/js/*.map
                '';

                installPhase = ''
                  mkdir -p $out/{bin,share}
                  mkdir -p $public
                  cp -r ./{app,config,public,config.ru,Rakefile,lib,db} $out/share/
                  cp -r ./public/* $public/
                  ln -s /tmp/${name} $out/share/tmp

                  makeWrapper ${gems}/bin/rake $out/bin/${name}-rake \
                    --set-default RAILS_ENV "$RAILS_ENV" \
                    --set BUNDLE_WITHOUT "$BUNDLE_WITHOUT" \
                    --run "${pkgs.coreutils}/bin/mkdir -p /tmp/${name}/" \
                    --add-flags "-I $out/share" \
                    --add-flags "-r $out/share/config/application.rb" \
                    --add-flags "-f $out/share/Rakefile" \

                  makeWrapper ${gems}/bin/puma $out/bin/${name}-puma \
                    --set-default RAILS_ENV "$RAILS_ENV" \
                    --set BUNDLE_WITHOUT "$BUNDLE_WITHOUT" \
                    --run "${pkgs.coreutils}/bin/mkdir -p /tmp/${name}/" \
                    --set-default PIDFILE "/tmp/${name}/server.pid" \
                    --add-flags "-C $out/share/config/puma.rb" \
                    --add-flags "$out/share/config.ru" \

                '';
              };

            };
          }
    );
}
