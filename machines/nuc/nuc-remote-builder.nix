{
  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true;

  nix.buildMachines = [
    {
      hostName = "100.118.230.21:2227";
      protocol = "ssh-ng";
      sshUser = "nixremote";
      sshKey = "/root/.ssh/nixos-vbox-builder";
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU56bXlJZytvNmJIOWQyREVPS3c3a3FrRlAwY0x1bXFhamZLVStlSVpHUWMgcm9vdEBuaXhvcy1sYWIK";
      system = "x86_64-linux";
      maxJobs = 3;
      speedFactor = 2;
      supportedFeatures = [ "big-parallel" ];
    }
  ];
}
