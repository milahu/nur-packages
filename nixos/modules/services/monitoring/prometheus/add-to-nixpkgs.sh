#!/usr/bin/env bash

# TODO services.prometheus: refactor to modular prometheus exporters
# https://github.com/milahu/nixpkgs/issues/73

#set -x # debug

nixpkgs="$1"
if [ -z "$nixpkgs" ]; then
  echo "error: argv1 must be path to your nixpkgs"
  exit 1
fi
nixpkgs="$(realpath "$nixpkgs")"
echo "nixpkgs: $nixpkgs"

nur="$(realpath "$(dirname "$0")/../../../../..")"
echo "nur-packages: $nur"

cd "$nixpkgs"



exporters_nix=nixos/modules/services/monitoring/prometheus/exporters.nix
echo "patching $nixpkgs/$exporters_nix"
patch --forward --reject-file=- -p1 < "$nur/$exporters_nix.diff"
git diff "$exporters_nix"

qbittorrent_nix=nixos/modules/services/monitoring/prometheus/exporters/qbittorrent.nix
echo "adding $nixpkgs/$qbittorrent_nix"
cp "$nur/$qbittorrent_nix" "$nixpkgs/$qbittorrent_nix"

cat <<EOF
done patching nixpkgs



next: add this to your /etc/nixos/configuration.nix

{ config, pkgs, lib, modulesPath, inputs, ... }:

{
  # override nixos modules
  # https://stackoverflow.com/a/46407944/10440128
  # see also: nixos/modules/module-list.nix
  disabledModules = [
    # override services.prometheus.exporters
    "services/monitoring/prometheus/exporters.nix"
  ];

  imports = [
    ./hardware-configuration.nix

    # override services.prometheus.exporters
    $nixpkgs/$exporters_nix
  ];

EOF

cat <<'EOF'
  services.grafana = {
    enable = true;
    declarativePlugins = with pkgs.grafanaPlugins; [
      grafana-piechart-panel # for prometheus-qbittorrent-exporter
    ];
    settings = {
      # ...
    };
  };

  services.prometheus = {
    enable = true;
    port = 9001;
    # /var/lib/prometheus2/
    #retentionTime = "15d"; # default -> 80 MB
    retentionTime = "740d"; # 2 years -> 4 GB
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9002;
      };
      qbittorrent = {
        enable = true;
        port = 9003;
        qbittorrentPort = 1952;
        package = pkgs.nur.repos.milahu.prometheus-qbittorrent-exporter;
      };
    };
    scrapeConfigs = [
      {
        job_name = "chrysalis";
        static_configs = [{
          targets = [
            "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
            "127.0.0.1:${toString config.services.prometheus.exporters.qbittorrent.port}"
          ];
        }];
      }
    ];
  };

}
EOF
