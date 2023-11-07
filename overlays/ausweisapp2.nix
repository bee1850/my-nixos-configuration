final: prev:
{
  AusweisApp2 = prev.AusweisApp2.overrideAttrs (old: rec {
    version = "1.26.4";
    src = prev.fetchFromGitHub {
      owner = "Governikus";
      repo = "AusweisApp2";
      rev = version;
      hash = "sha256-l/sPqXkr4rSMEbPi/ahl/74RYqNrjcb28v6/scDrh1w=";
    };
  });
}
