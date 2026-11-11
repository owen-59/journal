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

    packages = [
        pkgs.flutter
    ];

    processes.frontend-build-watcher = {
        exec = "cd frontend && dart run build_runner watch";
        env.FLUTTER_ROOT = "${pkgs.flutter}";
    };

    env.FLUTTER_ROOT = "${pkgs.flutter}";
}
