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
            system = "x86_64-linux";
            specialArgs = attrs;
            modules = [ ./configuration.nix ];
          };
      };
  };
}

