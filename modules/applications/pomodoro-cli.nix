{ lib, pkgs, buildDotnetModule, dotnetCorePackages }:
let
  pomodoro-cli =
    buildDotnetModule {
      pname = "pomodoro-cli";
      version = "1.0.0";

      src = pkgs.fetchFromGitHub {
        owner = "nrkno";
        repo = "pomodoro-cli";
        rev = "f3748f3c724e9d21e991641a7c97903ef9855371";
        sha256 = "RFYKXgrxsm2Q2Txm3rVW3J3kDf3GBQ4+YK3Knk2n6Lw=";
      };

      projectFile = "pomodoro-cli.fsproj";
      selfContainedBuild = true;
    };
  wrap-pomodoro = location:
    (pkgs.writeShellApplication {
      name = "pom";
      runtimeInputs = [ pomodoro-cli ];
      text = "(mkdir -p ${location} && cd ${location} && exec pom \"$@\")";
    });
in
wrap-pomodoro "/home/n651227/.config/pomodoro-cli"
