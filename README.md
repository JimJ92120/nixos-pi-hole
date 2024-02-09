# nixos-pi-hole

An example to run `pi-hole` with `docker` in a Raspberry Pi device (`arm` based device).  
Refer to [NixOS `arm` documentation](https://nixos.wiki/wiki/NixOS_on_ARM) for boards' specifications.

Example has been tested on a `Raspberry Pi 4` (`4GB`) and a `Raspberry Pi Zero 2 WH`.

### important notes

- ensure that no sensitive data (e.g credentials) are passed and store into `/nix/store`.
- update the default user password with `sudo passwd $USER_NAME`

---

---

# build and write image

```sh
# example variables

### the SD card /dev/ path
SD_CARD='/dev/sda'

### the image name (output after step 1)
IMAGE_NAME='nixos-sd-image-...-linux.img'
```

### 1. update variables in `configuration.nix` (system configuration) and `docker.nix` (containers)

### 2. build the image from `./configuration.nix`

```sh
export NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1

nix-build '<nixpkgs/nixos>' -A config.system.build.sdImage -I nixos-config=./configuration.nix
```

Some `read-only` permission may occur.  
Copy the `result/sd-image/${IMAGE_NAME}.zst` file to another location if this happens.

```sh
cp "result/sd-image/${IMAGE_NAME}.zst" /path/to/new/location/

cd /path/to/new/location/
```

### 3. de-compress the `.img.zst` output file

```sh
unzstd -d "${IMAGE_NAME}.zst"
```

### 4. write `.img` to SD card

```sh
# write to sd card
sudo dd if=$IMAGE_NAME of=$SD_CARD bs=4096 conv=fsync status=progress
```

### 5. mount the card on the target device

### 6. update `nix-channel`

By default `nix-channel` is not updated.  
This may cause issue such as `nixpkgs` or `$NIX_PATH` not found though already set.

Following may be run:

```sh
sudo -i nix-channel --update
```

---

---

# docker

`docker` and `docker-compose` are setup as `root` (to change).

Files may be copied over via e.g `scp` or additional `nix` tools may be used (e.g `oci-containers`, `arion`).  

The current example uses `oci-containers` to run `pi-hole` as a service.  

See [NixOS Docker documentation](https://nixos.wiki/wiki/Docker).

---

# pi-hole

### change password

```sh
docker exec -it pi-hole /bin/bash

#
pihole -a -p
```

---

---

# documentation and links

- https://rbf.dev/blog/2020/05/custom-nixos-build-for-raspberry-pis/
- https://nixos.org/manual/nixos/stable/#sec-building-image-instructions
- https://nixos.wiki/wiki/NixOS_on_ARM/Raspberry_Pi
- https://nixos.wiki/wiki/Docker
- https://github.com/pi-hole/docker-pi-hole
