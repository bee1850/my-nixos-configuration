let

  githubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAVcE4X0CHiRy1GYX00HnUu7u1qgWZBcZaVYf3BzhSvN";
  ];

  prometheus = {
    berkan = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAVcE4X0CHiRy1GYX00HnUu7u1qgWZBcZaVYf3BzhSvN";
    host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF+O0p1C/QW+IpwgUtv/Nr1sgUHgqIjw1qHQ6U6Nuw6H";
  };

  hosts = [ prometheus ];

  getUser = host: host.user;
  getHostPub = host: host.host;
  getAllKeysForHOst = host: [ (getUser host) (getHostPub host) ];

  knownUsers = (builtins.map getUser hosts);
  users = githubKeys ++ knownUsers;
  systems = (builtins.map getHostPub hosts);
  allKeys = users ++ systems;


in
{
  "berkan-pw.age".publicKeys = allKeys;
}
