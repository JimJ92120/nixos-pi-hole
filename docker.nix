# https://nixos.wiki/wiki/Docker
# https://mynixos.com/options/virtualisation.oci-containers.containers.%3Cname%3E
{ pkgs, ...}:

let
  TZ = "...";
  PI_HOLE_PASSWORD = "...";
in
{
  environment.systemPackages = with pkgs; [
    docker-compose
  ];

  virtualisation.docker = {
    enable = true;

    # port to adjust
    # rootless = {
    #   enable = true;
    #   setSocketVariable = true;
    # };
  };


  virtualisation.oci-containers = {
    backend = "docker";

    containers = {
      # https://github.com/pi-hole/docker-pi-hole
      "pi-hole" = {
        image = "pihole/pihole:latest";
        autoStart = true;

        ports = [
          "53:53/tcp"
          "53:53/udp"
          "67:67/udp"
          "80:80/tcp"
        ];

        environment = {
          TZ = TZ;
          WEBPASSWORD = PI_HOLE_PASSWORD;
        };

        volumes = [
          "./data/etc-pihole:/etc/pihole"
          "./data/etc-dnsmasq.d:/etc/dnsmasq.d"
        ];

        extraOptions = [
          "--cap-add=NET_ADMIN"
          "--cpus='0.5'"
          "--memory='256M'"
        ];
      };
    };
  };
}
