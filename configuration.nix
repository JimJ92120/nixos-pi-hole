{ pkgs, lib, ... }:

let
  SSH_PORT = 1234;

  USER_NAME = "pi-hole";
  USER_PASSWORD = "...";
  USER_GROUPS = [
    "wheel"
    "docker"
  ];
  USER_SSH_PUBLIC_KEY = "ssh-ed25519 ...";

  WLAN_SSID = "";
  WLAN_PASSWORD = "";
  WLAN_INTERFACE = "wlan0";

  DEFAULT_GATEWAY = "192.168.1.1";
  STATIC_IP = "192.168.1.123";
in
{
  imports = [
    ./image.nix
    ./hardware-configuration.nix

    ./docker.nix
  ];

  system.stateVersion = "23.11";

  users = {
    mutableUsers = true;

    users."${USER_NAME}" = {
      isNormalUser = true;
      initialPassword  = USER_PASSWORD;
      extraGroups = USER_GROUPS;
      openssh.authorizedKeys.keys = [
        USER_SSH_PUBLIC_KEY
      ];
    };
  };

  /*
    SSH
    - disable password authentication
    - ed25519 keys only
    - non-default 22 port
  */
  services.openssh = {
    enable = true;
    ports = [ 
      SSH_PORT
    ];

    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = lib.mkForce "no";
      KexAlgorithms = [
        # ssh-ed25519
        "curve25519-sha256"
        "curve25519-sha256@libssh.org"
      ];
    };
  };

  /*
    Networking (for wlan0 interface, no NetworkManager)
    - disable DHCP
    - use static IP
    - use default gateway
    - restricted firewall
    - intial wireless connection
  */
  networking = {
    hostName = USER_NAME;
    useDHCP = lib.mkForce false;

    nameservers = [DEFAULT_GATEWAY];
    defaultGateway = {
      address = DEFAULT_GATEWAY;
      interface = WLAN_INTERFACE ;
    };

    interfaces = {
      "${WLAN_INTERFACE}" = {
        useDHCP = lib.mkForce false;

        ipv4.addresses = [{
          address = STATIC_IP;
          prefixLength = 24;
        }];
      };
    };

    firewall = {
      enable = true;

      # set empty and force to declare per interface
      allowedTCPPorts = [
        # ssh
        SSH_PORT
        # pi-hole
        80 53
      ];
      allowedUDPPorts = [
        # pi-hole
        53 67
      ];
    };
    
    wireless = {
      enable = true;

      networks."${WLAN_SSID}" = {
        psk = "${WLAN_PASSWORD}";
      };
    };
  };

  environment.systemPackages = with pkgs;  [
    htop
    nano
    nmap
    nettools
    iputils
    unzip
    usbutils
  ];
}
