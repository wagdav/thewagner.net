let
  revision = "9237a09d8edbae9951a67e9a3434a07ef94035b7";
  sha256 = "05bizymljzzd665bpsjbhxamcgzq7bkjjzjfapkl2nicy774ak4x";

  nixpkgs = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${revision}.tar.gz";
    inherit sha256;
  };

  pkgs = import nixpkgs { };

in pkgs
