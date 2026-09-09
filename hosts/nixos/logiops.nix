{ pkgs, config, ... }:

{
  # Create systemd service
  # https://github.com/PixlOne/logiops/blob/5547f52cadd2322261b9fbdf445e954b49dfbe21/src/logid/logid.service.in
  systemd.services.logiops = {
    description = "Logitech Configuration Daemon";
    startLimitIntervalSec = 0;
    after = [ "graphical.target" ];
    wantedBy = [ "graphical.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.logiops_0_2_3}/bin/logid";
      User = "root";
      Restart = "on-failure";
      RestartSec = "5s";
    };
    restartTriggers = [
      config.environment.etc."logid.cfg".source
    ];
  };

  # This is needed since the mouse config isn't applied after resuming from suspend for some reason
  systemd.services.logiops-resume = {
    description = "Restart logiops after resume";
    after = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
    wantedBy = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl restart logiops.service";
    };
  };

  # Configuration for logiops
  environment.etc."logid.cfg".text = /* json */ ''
    devices: ({
      name: "Wireless Mouse MX Master 3";
      smartshift: {
        on: true;
        threshold: 12;
      };
      hiresscroll: {
        hires: true;
        target: false;
      };
      dpi: 1200;
      buttons: ({
        cid: 0xc3;
        action: {
          type: "Gestures";
          gestures: ({
            direction: "Left";
            mode: "OnRelease";
            action: {
              type: "Keypress";
              keys: ["KEY_LEFTMETA", "KEY_C"];
            };
          }, {
            direction: "Right";
            mode: "OnRelease";
            action: {
              type: "Keypress";
              keys: ["KEY_LEFTMETA", "KEY_V"];
            };
          }, {
            direction: "Down";
            mode: "OnRelease";
            action: {
              type: "Keypress";
              keys: ["KEY_F17"];
            };
          }, {
            direction: "Up";
            mode: "OnRelease";
            action: {
              type: "Keypress";
              keys: ["KEY_F18"];
            };
          }, {
            direction: "None";
            mode: "OnRelease";
            action: {
              type: "Keypress";
              keys: ["KEY_ENTER"];
            };
          });
        };
      }, {
        cid: 0xc4;
        action: {
          type: "Keypress";
          keys: [ "KEY_LEFTCTRL", "KEY_LEFTALT", "KEY_M" ];
        };
      });
    });
  '';
}
