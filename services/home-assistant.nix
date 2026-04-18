{ outputs, config, pkgs, lib, ... }:
{
    virtualisation = {
    libvirtd = {
        enable = true;
        qemuOvmf = true;
        };
    };

    environment.systemPackages = with pkgs; [
    # For virt-install
    virt-manager

    # For lsusb
    usbutils
    ];

    # Access to libvirtd
    users.users.myme = {
    extraGroups = ["libvirtd"];
    };


    networking.defaultGateway = "192.168.0.1";
    networking.bridges.br0.interfaces = ["eno1"];
    networking.interfaces.br0 = {
        useDHCP = false;
        ipv4.addresses = [{
            "address" = "192.168.0.108";
            "prefixLength" = 24;
        }];
    };
}
