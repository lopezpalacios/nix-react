{requirementsFile
, postgres
,pkgs
}:
with pkgs;
let pyenv = import ../python/py.nix {inherit requirementsFile;};
  postgresql = with pkgs;
              postgres.overrideAttrs (oldAttrs: {
                buildInputs = oldAttrs.buildInputs or [] ++ [pyenv];
                configureFlags = oldAttrs.configureFlags or [] ++ ["--with-python"];
                propagatedBuildInputs = oldAttrs.propagatedBuildInputs or [] ++ [pyenv];
              });

  postgresqlExtensions = with postgresql.pkgs; [
    pg_cron
    pgtap
    pg_partman
  ];

  postgresqlWithPackages = pkgs.buildEnv{
    name = "postgresql-and-plugins-${postgresql.version}";

    paths = postgresqlExtensions ++ [ postgresql postgresql.lib ];
    buildInputs = [ pkgs.makeWrapper ];

    pathsToLink = ["/" "/bin"];

    postBuild = ''
      mkdir -p  $out/bin
      rm $out/bin/{pg_config,postgres,pg_ctl}
      cp --target-directory=$out/bin ${postgresql}/bin/{postgres,pg_config,pg_ctl}
      wrapProgram $out/bin/postgres --set NIX_PGLIBDIR $out/lib
    '';
    passthru.version = postgresql.version;
    passthru.psqlSchema = postgresql.psqlSchema;


  };

  in postgresqlWithPackages