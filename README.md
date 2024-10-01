# Optimize-Container-Security-With-Nix-and-Docker

This repository is the example used for the Talk on October 11th 2024 @ 8pm for the HackFest Quebec City.

## Spoilers ahead ! BE WARNED !

<details>
<summary>Initialise the project</summary>
<br />
  There are multiple templates out there, but I will be using the empty template

  ![image](https://github.com/user-attachments/assets/95db55a4-06d1-4767-8ca4-4932bac7b1f7)

  ```nix
  {
    outputs = {self}: { };
  }
  ```
  It generates a sad empty project. Let's give it some life.
</details>

<details>
<summary>The Inputs</summary>
  Flake uses the input to define the repository from which it will fetch the dependencies.

  ```nix
  {
    inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    outputs = { self, nixpkgs }: { };
  }
  ```

  In this case, we are using the unstable `nixpkgs` repository from NixOS.
</details>


<details>
  <summary>Take Advantage of Nix</summary>
  Before talking about the outputs, let's take advantage of Nix multiplatform support.

  ```nix
  {
    inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    outputs = { self, nixpkgs }:
    let

      # System types to support.
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
    };
  }
  ```
  We have no outputs yet, but we are now able to support multiple platforms.

</details>

<details>
<summary>The Outputs</summary>
  Let's define the `outputs` of the project. Let's start by packaging our API for the container.

  ```nix
  {
    inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    outputs = { self, nixpkgs }:
    let
      # System types to support.
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
        packages = forAllSystems(
            system:
            let
                pkgs = nixpkgsFor.${system};
            in
            {
                awesome-api = pkgs.buildGo123Module {
                    pname = "awesome-api";
                    version = "0.1.0";
                    src = "${./src}";

                    vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAA";
                };
            };
        );
    };
  }
  ```
  Running `nix build .#awesome-api` will build the API for your system if it is supported by Nix.
</details>

<details>
  <summary>How about a container?</summary>

  ```nix
  {
    inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    outputs = { self, nixpkgs }:
    let
      # System types to support.
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
        packages = forAllSystems(
            system:
            let
                pkgs = nixpkgsFor.${system};
            in
            {
                awesome-api = pkgs.buildGo123Module {
                    pname = "awesome-api";
                    version = "0.1.0";
                    src = "${./src}";

                    vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAA";
                };
                container = pkgs.dockerTools.buildImage {
                  name = "awesome-api-container";
                  tag = "latest";
                  copyToRoot = [
                    self.packages.${system}.awesome-api
                  ];
                  config = {
                    ExposedPorts = {
                      "8080/tcp" = { };
                    };
                    Entrypoint = [ "${self.packages.${system}.awesome-api}/bin/awesome-api" ];
                    Cmd = [ ];
                  };
                  diskSize = 1024;
                };
            };
        );
    };
  }
  ```
</details>
