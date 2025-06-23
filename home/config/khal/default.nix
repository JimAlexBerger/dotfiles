{ config, ... }:
{
  accounts.calendar = {
    basePath = "Calendar";

    accounts.personal_gmail = {
      remote.type = "google_calendar";

      vdirsyncer = {
        enable = true;
        collections = [ "from a" ];

        tokenFile = "~/.config/vdirsyncer/google_calendar_token";
        clientIdCommand = [
          "sh"
          "-c"
          "cat ${config.sops.secrets.calendar-google-client-id.path}"
        ];
        clientSecretCommand = [
          "sh"
          "-c"
          "cat ${config.sops.secrets.calendar-google-client-secret.path}"
        ];
      };

      khal = {
        enable = true;
        type = "discover";
      };
    };
  };

  programs.khal = {
    enable = true;

    locale = {
      dateformat = "%Y-%m-%d";
      longdateformat = "%Y-%m-%d";
      timeformat = "%H:%M:%S";
      datetimeformat = "%Y-%m-%dT%H:%M:%S";
      longdatetimeformat = "%Y-%m-%dT%H:%M:%S";
    };
  };

  programs.vdirsyncer.enable = true;
  services.vdirsyncer.enable = true;

  sops.secrets = {
    calendar-google-client-id = {
      sopsFile = ../../../secrets/calendar/vdirsyncer.yaml;
      key = "client_id";
    };
    calendar-google-client-secret = {
      sopsFile = ../../../secrets/calendar/vdirsyncer.yaml;
      key = "client_secret";
    };
  };
}
