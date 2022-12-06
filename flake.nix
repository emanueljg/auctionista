{
  description = "An exercise in building a REST api.";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;

  outputs = { self, nixpkgs, ... }: {
    nixosModules = let name = "auctionista"; in {
      # why it can't rec properly I don't know
      # have to reach it through self.nixosModules...
      default = self.nixosModules.${name}; 
      ${name} = (
        { config, pkgs, lib, ... }: with lib; let 
          cfg = config.services.${name}; in {

          options.services.${name} = {
            enable = mkEnableOption self.description;
          };

          config = mkIf cfg.enable {
            users.users.${name} = {
              isSystemUser = true;
              shell = mkForce pkgs.bash; 
              group = name;
            };
            users.groups.${name} = { };

            # setup db stuff
            services.mysql = {
              # create db
              ensureDatabases = [ name ];

              # create db user and give priveleges
              ensureUsers = [
                {
                  inherit name;
                  ensurePermissions = {
                    "${name}.*" = "ALL PRIVILEGES";
                  };
                }

                {
                  name = "ejg";
                  ensurePermissions = {
                    "${name}.*" = "ALL PRIVILEGES";
                  };
                }
              ];
            };
          };
        }
      );
    };
  };
}

