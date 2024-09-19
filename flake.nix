{
  inputs = {
    nixpkgs = {
        url = "github:NixOS/nixpkgs/nixos-unstable";
    };
  };
  outputs = { self, nixpkgs }:
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in
  {
    default = pkgs.dockerTools.buildLayeredImage {
      name = "Hello-World";
      tag = "latest";
      contents = [

      ];
    };

    devShell.x86_64-linux = pkgs.mkShell {
      buildInputs = [
        pkgs.go_1_23
      ];
    };
  };
}
