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

<details>
  <summary>Building the container</summary>

  ```bash
  nix build .#container
  ```

  This will build the container for your system if it is supported by Nix.
  
  ![nix_build_and_load](https://github.com/user-attachments/assets/47288aa8-2e47-4ae7-8c0f-b2390cc26a44)

  As you can see the image is much smaller

  Now! Let's see with Docker:

  ![building_docker](https://github.com/user-attachments/assets/819630fa-ba2c-4ed1-9be6-e85d45b7f16c)

  The difference is incredible!
  
  ![image](https://github.com/user-attachments/assets/30911e58-54d0-4aed-af46-992c4aae3d85)


</details>

<details>
  <summary>Let's run some command on these containers</summary>

  Let's run our Nix built container and try to run a few command. 
  
  ![image](https://github.com/user-attachments/assets/d8a878eb-d4ba-4ca5-bf99-7b541b21090a)

  What about Docker?
  ![image](https://github.com/user-attachments/assets/b8ed2944-4c61-497d-918b-13eeec364de7)
  ![image](https://github.com/user-attachments/assets/cc466553-1b8d-4e97-a44e-4da718ec9ae7)


</details>
