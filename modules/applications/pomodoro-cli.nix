{ pkgs, buildDotnetModule, location ? "$HOME/.config/pomodoro-cli" }:
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
  wrap-pomodoro = loc:
    (pkgs.writeShellApplication {
      name = "pom";
      runtimeInputs = [ pomodoro-cli ];
      text = "(mkdir -p \"${loc}\" && cd \"${loc}\" && exec pom \"$@\")";
    });
in
wrap-pomodoro location
