{ config, pkgs, lib, home-manager, self, ... }:

{
  imports = #{{{
    [
      home-manager.nixosModules.default
    ];
  #}}}

  boot.loader.timeout = lib.mkForce 1;

  services = #{{{
    {
      openssh = #{{{
        {
          enable = true;
        };
      #}}}
    };
  #}}}

  systemd.services.autoinstall = #{{{
    {
      enable = true;
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      path = [ pkgs.nixos-install-tools pkgs.util-linux pkgs.dosfstools pkgs.e2fsprogs pkgs.coreutils-full pkgs.ethtool pkgs.findutils pkgs.kmod pkgs.btrfs-progs pkgs.git pkgs.nix pkgs.gnugrep pkgs.bash ];

      script =
        ''
          #cp -rL /root/realix /tmp
          #bash -c /tmp/realix/isoinstall.sh
        '';
    };
  #}}}

  system = #{{{
    {
      stateVersion = "24.05";
    };
  #}}}

  networking = #{{{
    {
      useNetworkd = true;
      hostName = "realix-iso";
      firewall = #{{{
        {
          enable = true;
          #allowedTCPPorts = [ ];
        };
      #}}}
    };
  #}}}

  virtualisation = #{{{
    {
      vmware.guest.enable = true;
    };
  #}}}

  users.users.root = #{{{
    {
      password = "toto";
    };
  #}}}

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.root = #{{{
    {
      home.username = "root";
      home.homeDirectory = "/root";
      home.packages = [
        # # Adds the 'hello' command to your environment. It prints a friendly
        # # "Hello, world!" when run.
        # pkgs.hello

        # # It is sometimes useful to fine-tune packages, for example, by applying
        # # overrides. You can do that directly here, just don't forget the
        # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
        # # fonts?
        # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

        # # You can also create simple shell scripts directly inside your
        # # configuration. For example, this adds a command 'my-hello' to your
        # # environment:
        pkgs.home-manager
      ];
      home.stateVersion = "24.05";
      home.file.".local/bin" = {
        recursive = true;
        source = "${self}/iso_data/bin";
      };
      home.file."realix" = {
        recursive = true;
        source = "${self}/iso_data/realix";
      };
    };
  #}}}

  environment =
    {
      localBinInPath = true;
      systemPackages = with pkgs; #{{{
        [
          gnugrep
          git
          btop
          btrfs-progs
        ];
      #}}}
    };

}
