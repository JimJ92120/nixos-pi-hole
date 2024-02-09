{ modulesPath, lib, ... }:

{
  # https://nixos.wiki/wiki/NixOS_on_ARM#Installation
  # https://nix.dev/tutorials/nixos/installing-nixos-on-a-raspberry-pi.html
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
  ];

  system.copySystemConfiguration = lib.mkForce true;
}
