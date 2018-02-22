{ config, lib, pkgs, ... }:

let
  makeContainer = { name, packages, config ? {} }:
    {
      bindMounts = {
        "/home/brodavi/${name}" = {
          hostPath = "/home/brodavi/shared/src/${name}";
          isReadOnly = false;
        };

        "/home/brodavi/.ssh" = {
          hostPath = "/home/brodavi/.ssh";
          isReadOnly = true;
        };

        "/home/brodavi/.gitconfig" = {
          hostPath = "/home/brodavi/.gitconfig";
          isReadOnly = true;
        };
      };

      config = {
        services.openssh.enable = true;

        users.users = {
          brodavi = {
            home = "/home/brodavi";
            extraGroups = ["wheel" "wwwrun" "mysql"];
            isNormalUser = true;
            uid = 1000;
            shell = pkgs.zsh;
          };
        };

        environment.systemPackages = let
          packages2 = with pkgs; [
            git vim tmux zsh oh-my-zsh
          ];
        in lib.mkMerge [
          packages
          packages2
        ];

        programs.zsh.enable = true;

        # Extra config for zsh/oh-my-zsh
        programs.zsh.interactiveShellInit = ''
          export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh/

          # Customize your oh-my-zsh options here
          ZSH_THEME="agnoster"
          plugins=(git)

          # Remove the need for -g npm installs
          export PATH="/home/brodavi/${name}/node_modules/.bin":$PATH

          source $ZSH/oh-my-zsh.sh
        '';

        programs.zsh.promptInit = ""; # Clear this to avoid a conflict with oh-my-zsh
      } // config;
    };

in

{
  containers.ec-client = (
    makeContainer {
      name = "ec-client";
      packages = [
        pkgs.nodejs-9_x
      ];
    }
  );

  containers.gn-into-test-integrations = (
    makeContainer {
      name = "gn-into-test-integrations";
      packages = [
        pkgs.nodejs-9_x
      ];
    }
  );

  containers.gn-into-widget = (
    makeContainer {
      name = "gn-into-widget";
      packages = [
        pkgs.python
        pkgs.gnumake
        pkgs.binutils
        pkgs.gcc
        pkgs.nodejs-6_x
      ];
    }
  );

  containers.facilitator-bot = (
    makeContainer {
      name = "facilitator-bot";
      packages = with pkgs; [
        nodejs-9_x
      ];
    }
  );

  containers.sevgen-design-system = (
    makeContainer {
      name = "sevgen-design-system";
      packages = [
        pkgs.yarn
        pkgs.nodejs-9_x
        pkgs.php
        pkgs.php71Packages.xdebug
        pkgs.php71Packages.composer
        pkgs.php71Packages.phpcs
      ];
    }
  );

  containers.sevgen-d8-cms = (
    makeContainer {
      name = "sevgen-d8-cms";
      packages = [
        pkgs.yarn
        pkgs.nodejs-9_x
        pkgs.php
        pkgs.php71Packages.xdebug
        pkgs.php71Packages.composer
        pkgs.php71Packages.phpcs
        pkgs.drush
        pkgs.mariadb
      ];
      config = {
        nixpkgs.config.php = {
          mysqlnd = true;
        };

        services.httpd = {
          enable = true;
          user = "brodavi";
          adminAddr = "david@colab.coop";
          documentRoot = "/var/www";
          enablePHP = true;
          phpOptions = ''
            zend_extension="${pkgs.php71Packages.xdebug}/lib/php/extensions/xdebug.so"
            zend_extension_ts="${pkgs.php71Packages.xdebug}/lib/php/extensions/xdebug.so"
            zend_extension_debug="${pkgs.php71Packages.xdebug}/lib/php/extensions/xdebug.so"
            xdebug.remote_enable=true
            xdebug.remote_host=127.0.0.1
            xdebug.remote_port=9000
            xdebug.remote_handler=dbgp
            xdebug.profiler_enable=0
            xdebug.profiler_output_dir="/tmp/xdebug"
            xdebug.remote_mode=req
          '';

          virtualHosts = [
            {
              hostName = "sevgen-d8.test";
              documentRoot = "/home/brodavi/sevgen-d8-cms/docroot";
              extraConfig = ''
                DirectoryIndex index.php
                <Directory "/home/brodavi/sevgen-d8-cms/docroot">
                  AllowOverride All
                </Directory>
              '';
            }
          ];
        };

        # NOTE: must set settings.local.php host to 127.0.0.1
        services.mysql.enable = true;
        services.mysql.package = pkgs.mariadb;
      };
    }
  );
}
