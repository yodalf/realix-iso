{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@attrs: {
    nixosConfigurations =
      {
        gizmo = nixpkgs.lib.nixosSystem
          {
            system = "aarch64-linux";
            specialArgs = attrs;
            modules = [ ./configuration.nix ];
          };
      };
  };
}

