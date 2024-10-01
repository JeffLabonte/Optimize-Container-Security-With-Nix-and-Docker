# Optimize-Container-Security-With-Nix-and-Docker

This repository is the example used for the Talk on October 11th 2024 @ 8pm for the HackFest Quebec City.

## Spoilers ahead ! BE WARNED !

<details>
<summary>Initialise the project</summary>
<br />
  There are multiple templates out there, but I will be using the empty template
  
  ![image](https://github.com/user-attachments/assets/95db55a4-06d1-4767-8ca4-4932bac7b1f7)

  ```bash
  cat flake.nix
  ```
  ![image](https://github.com/user-attachments/assets/08ddc7a4-a409-47d8-a8df-96a4ded483b0)

  Now, it generates nothing and take no input! Let's change that!
</details>

<details>
<summary>The Inputs</summary>
  Flake works with `inputs` and `outputs`, so let's add the first input.

  In this example, I am using nixos-unstable. I want the latest version of software for this project.

  ![image](https://github.com/user-attachments/assets/f465fb12-4ad0-41b8-9af5-ac78c37d1f4e)

</details>

<details>
  <summary>Take Advantage of Nix</summary>
  This code block is there to help deal with multiple CPU Architecture and Operating System.

  ![image](https://github.com/user-attachments/assets/da91f522-8939-4510-839d-d54c6e1cb311)

</details>
