# https://nixos.wiki/wiki/Docker
{ pkgs, ...}:

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
}
