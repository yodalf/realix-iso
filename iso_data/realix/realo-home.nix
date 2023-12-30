{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "realo";
  home.homeDirectory = "/home/realo";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
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
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    pkgs.home-manager
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    ".vimrc" =
      {
        source = "/etc/nixos/vim/.vimrc";
      };
    ".vim" =
      {
        recursive = true;
        source = "/etc/nixos/vim/.vim";
      };
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/realo/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "vim";
    # EDITOR = "emacs";
  };

  dconf.settings = #{{{
    {
      "org/gnome/desktop/session" = { idle-delay = "uint32 0"; };
      "org/gnome/desktop/screensaver" = { lock-enabled = false; };
      "org/gnome/desktop/notifications" = { show-in-lock-screen = false; };

      "org/gnome/desktop/interface" =
        {
          color-scheme = "prefer-dark";
          enable-hot-corners = false;
        };

      "org/gnome/desktop/background" =
        {
          picture-uri = "file:///etc/nixos/realixix/Terraform-blue.jpg";
          picture-uri-dark = "file:///etc/nixos/realix/Terraform-blue.jpg";
        };


      "org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9" =
        {
          use-theme-colors = false;
          background-color = "rgb(10,10,10)";
          foreground-color = "rgb(228,178,30)";
          use-system-font = false;
          font = "Source Code Pro 11";
          default-size-columns = 130;
          default-size-rows = 32;
          visible-name = "ABB";
        };

      "org/gnome/shell" =
        {
          enabled-extensions =
            [
              "launch-new-instance@gnome-shell-extensions.gcampax.github.com"
              "window-list@gnome-shell-extensions.gcampax.github.com"
            ];
          favorite-apps =
            [
              "org.gnome.Terminal.desktop"
              "gnome-system-monitor.desktop"
              "nixos-manual.desktop"
            ];
        };

      "org/gnome/gnome-system-monitor" =
        {
          current-tab = "resources";
        };

    };
  #}}} 
  programs = #{{{
    {
      home-manager.enable = true;
      fish = #{{{
        {
          enable = true;

          functions =
            {
              fish_prompt =
                {
                  body = ''
                    set laststatus $status
                    set -g __fish_git_prompt_show_informative_status 1
                    set -g __fish_git_prompt_describe_style describe
                    set -g __fish_git_prompt_showcolorhints 1

                    set IP (ip a | grep ens | grep inet | awk '{print $2}' | awk -F'/' '{print $1}')
                    
                    if [ "$USER" = root ]
                       echo -n -s (set_color -o red) "[$IP]" ' ' (set_color normal) (set_color -o cyan) (echo $PWD | sed -e "s|^$HOME|~|") (set_color normal) 
                       if test $laststatus -eq 0
                            printf "%s ✔%%s≻%s " (set_color -o green) (set_color white) (set_color normal)
                        else
                            printf "%s %✘s≻%s " (set_color -o red) (set_color white) (set_color normal)
                        end

                    else    

                        set_color -b normal
                        printf '%s%s%s%s%s%s%s%s%s%s%s%s%s' (set_color -o -d white) [$IP] ' ' (set_color -d -i cyan) (echo $PWD | sed -e "s|^$HOME|~|") (set_color normal)  
                    
                        fish_vcs_prompt 
                      
                   
                        if test $laststatus -eq 0
                            printf "%s ✔%s" (set_color -o green) (set_color normal)
                        else
                            printf "%s ✘%s" (set_color -o red) (set_color normal)
                        end
                        
                        # Check and display SHLVL if higher than 1
                        if test $SHLVL -gt 1
                          set -l nix_shell_level (math $SHLVL - 1)
                          printf "%s|+%s|%s" (set_color white) $nix_shell_level (set_color normal)
                        end
                        
                        printf "%s>%s " (set_color white) (set_color normal)
                        
                    end
                  '';
                };
            };

          interactiveShellInit = ''
            set fish_greeting # Disable greeting
          '';
          plugins =
            [
              # Enable a plugin (here grc for colorized command output) from nixpkgs
              { name = "grc"; src = pkgs.fishPlugins.grc.src; }
            ];
        };
      #}}}
    };
  #}}}
}
