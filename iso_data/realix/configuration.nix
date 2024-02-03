{ config, pkgs, lib, home-manager, ... }:

{
  imports = #{{{
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      home-manager.nixosModules.default
    ];
  #}}}

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";
  nixpkgs.config.allowUnfree = true;

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  zramSwap.enable = true;
  
  documentation.nixos.enable = false;
  documentation.man.enable = false;

  boot = #{{{
    {
      kernel.sysctl."net.ipv4.ip_forward" = true;
      binfmt.emulatedSystems = [ "aarch64-linux" "armv7l-linux" ];
      supportedFilesystems = [ "zfs" ];
      loader = #{{{
        {
          systemd-boot = #{{{
            {
              enable = true;
              configurationLimit = 3;
            };
          #}}}
          efi = #{{{
            {
              canTouchEfiVariables = true;
            };
          #}}}
        };
      #}}}
    };
  #}}}

  fileSystems = #{{{
    {
      "home" = #{{{
        {
          device = "/dev/disk/by-label/WORK";
          mountPoint = "/home";
          fsType = "btrfs";
          autoResize = true;
          neededForBoot = true;
          options = [ "compress=zstd" "noatime" ];
        };
      #}}}
    };
  #}}}

  system = #{{{
    {
      stateVersion = "24.05";
      autoUpgrade = #{{{
        {
          enable = true;
          allowReboot = true;
          dates = "02:00";
          flake = "/etc/nixos#gizmo";
          flags = #{{{
            [
              "--no-write-lock-file"
              "--impure"
            ];
          #}}}
          rebootWindow = #{{{
            {
              lower = "01:00";
              upper = "03:00";
            };
          #}}}
        };
      #}}}
    };
  #}}}

  systemd = #{{{
    {
      services = #{{{
        {
          "getty@tty1".enable = false;
          "autovt@tty1".enable = false;
        };
      #}}}
      network = #{{{
        {
          enable = true;
          wait-online.enable = false;
          # We do NOT enable networks here for nopw ... DHCP is in hardware-configuration.
          networks = #{{{
            {
              "10-front-end" = #{{{
                {
                  enable = false;
                  name = "en*";
                  DHCP = "yes";
                };
              #}}}
            };
          #}}}
        };
      #}}}
    };
  #}}}

  virtualisation = #{{{
    {
      vmware.guest.enable = true;
      docker =
        {
          enable = true;
        };
    };
  #}}}

  nix = #{{{
    {
      settings = #{{{
        {
          #experimental-features = [ "nix-command" "flakes" "repl-flake" "auto-allocate-uids" "configurable-impure-env"  ];
          experimental-features = [ "nix-command" "flakes" "repl-flake" ];
          max-jobs = "auto";
          cores = 0;
          auto-optimise-store = true;
          trusted-users = [ "root" "@wheel" ];
        };
      #}}}
      gc = #{{{
        {
          automatic = true;
          dates = "daily";
          options = "--delete-older-than 7d";
        };
      #}}}
    };
  #}}}

  security = #{{{
    {
      sudo.wheelNeedsPassword = false;
    };
  #}}}

  networking = #{{{
    {
      useNetworkd = true;
      #networkmanager.enable = true;
      hostName = "realix";
      hostId = "1234abcd";
      firewall = #{{{
        {
          enable = true;
        };
      #}}}
    };
  #}}}

  services = #{{{
    {
      btrfs = #{{{
        {
          autoScrub = #{{{
            {
              enable = true;
              interval = "daily";
              fileSystems = [ "/home" ];
            };
          #}}}
        };
      #}}}
      openssh = #{{{
        {
          enable = true;
        };
      #}}}
      xserver = #{{{
        {
          enable = true;
          desktopManager.gnome.enable = true;
          displayManager = #{{{
            {
              gdm.enable = true;
              autoLogin.enable = true;
              autoLogin.user = "realo";
            };
          #}}}
          layout = "us";
          xkbVariant = "";
        };
      #}}}
      zram-generator.enable = true;
    };
  #}}}

  users = #{{{
    {
      #defaultUserShell = pkgs.fish;
      users.realo = #{{{
        {
          password = "toto";
          isNormalUser = true;
          description = "realo";
          extraGroups = [ "networkmanager" "wheel" "docker" "dialout" ];
          shell = pkgs.fish;
          packages = with pkgs; [
          ];
        };
      #}}}
    };
  #}}}

  environment = #{{{
    {
      localBinInPath = true;
      systemPackages = with pkgs; #{{{
        [
          # Extra
          opensc
          libp11
          openssl
          pkcs11helper
          gnupg-pkcs11-scd
          cryptsetup
          osslsigncode
          gnutls
          gptfdisk
          multipath-tools 
          qemu-utils

          zip
          unzip
          squashfsTools
          cloud-utils
          chromium
          zfs
          jfrog-cli
          parallel
          jq
          cifs-utils
          docker-compose
          gnome.gnome-terminal
          gnome.gnome-tweaks
          vim_configurable
          wget
          git
          btop
          nixpkgs-fmt
          nix-tree
          grc
          fishPlugins.grc
        ];
      #}}}
      gnome.excludePackages = (with pkgs; #{{{
        [
          python3
          mbrola
          gnome-photos
          gnome-tour
        ]) ++ (with pkgs.gnome;
        [
          cheese # webcam tool
          gnome-music
          epiphany # web browser
          geary # email reader
          gnome-characters
          tali # poker game
          iagno # go game
          hitori # sudoku game
          atomix # puzzle game
          yelp # Help view
          gnome-contacts
          gnome-initial-setup
        ]);
      #}}}
    };
  #}}}

  programs = #{{{
    {
      nix-ld.enable = true;
      dconf.enable = true;
      fish.enable = true;
      fish.useBabelfish = true;
    };
  #}}}

  home-manager = #{{{
    {
      useGlobalPkgs = true;
      users.realo = ./realo-home.nix;
    };
  #}}}

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
}
