{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
    languages.javascript = {
        enable = true;
        package = pkgs.nodejs_24;
        nodejs.enable = true;
        pnpm.enable = true;
    };

    services.postgres.enable = true;
}
