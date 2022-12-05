{
  description = "An exercise in building a REST api.";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;

  outputs = { self, nixpkgs, ... }: {
    nixosModules = let name = "auctionista"; in {
      ${name} = (
        { config, lib, ... }: with lib; let 
          cfg = config.services.${name}; in {

          options.services.${name} = {
            enable = mkEnableOption self.description;
          };

          config = {

            # setup db stuff
            services.mysql = {
              # create db
              ensureDatabases = [ name ];

              # create db user and give priveleges
              ensureUsers = [{
                inherit name;
                ensurePermissions = {
                  "${name}.*" = "ALL PRIVILEGES";
                };
              }];
            };
          };
        }
      );
    };
  };
}
