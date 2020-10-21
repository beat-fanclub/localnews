
# Localnews

## Development setup

1. [Install Nix](https://nixos.org/manual/nix/stable/#chap-installation)

        sh <(curl -L https://nixos.org/nix/install) --daemon

2. Setup Nix flakes. ([Blog post](https://www.tweag.io/blog/2020-05-25-flakes/))

    1. Edit your nix configuration. Add the following options to `~/.config/nix/nix.conf`

        experimental-features = nix-command flakes

    2. Get a shell with flakes

        nix-shell -I nixpkgs=channel:nixos-20.09 --packages nixFlakes

3. Load the development environment

        nix develop

The database will automagically start when opening the development environment.

In the future, you can get an environment with these commands:

        nix-shell -I nixpkgs=channel:nixos-20.09 --packages nixFlakes
        nix develop

Start the server with:

        rails s

