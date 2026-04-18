let
 
  nuc = {
    user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHBc/+fAw+WNP2t1roeBnIjQOtMhsPtc1JrDb0V5BpPA";
  
    host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGhD41sW9Wq9O+fQKf9lJ9NFe7R2AsWZiGCDcmtj0kTg";
  };

  hosts = [ nuc ];

  getUser = host: host.user;
  getHostPub = host: host.host;
  getAllKeysForHOst = host: [ (getUser host) (getHostPub host) ];

  knownUsers = (builtins.map getUser hosts);
  # users = githubKeys ++ knownUsers;
  systems = (builtins.map getHostPub hosts);
  allKeys = systems; # users ++ systems;


in
{
  "nextcloud-admin-pass.age".publicKeys = allKeys;
  "nextcloud-s3-secret.age".publicKeys = allKeys;
  "minio-root-creds.age".publicKeys = allKeys;
  "nextcloud-sse-key.age".publicKeys = allKeys;
  "certificate.age".publicKeys = allKeys;
  "certificateKey.age".publicKeys = allKeys;
}
