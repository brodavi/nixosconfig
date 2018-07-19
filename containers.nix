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
            git vim tmux zsh oh-my-zsh file
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

          # same as above, but with ruby gems, unfortunately specifically for v2.3.0
          export PATH="/home/brodavi/.gem/ruby/2.4.0/bin":$PATH

          # need to point to zlib for project elmo
          export LD_LIBRARY_PATH="/nix/store/mzcxlf0izjjmwnyi83wma5llf5skr7cv-zlib-1.2.11-dev":$LD_LIBRARY_PATH
          export LD_LIBRARY_PATH="/nix/store/dn28qkm12bqwrdiaj7clv9zggnn8df60-libxml2-2.9.7-dev":$LD_LIBRARY_PATH

          source $ZSH/oh-my-zsh.sh
        '';

        programs.zsh.promptInit = ""; # Clear this to avoid a conflict with oh-my-zsh
      } // config;
    };

in

{
  containers.elmo = (
    makeContainer {
      name = "elmo";
      packages = with pkgs; [
        ruby_2_4 memcached imagemagick chromedriver graphviz nodejs-8_x gcc gnumake binutils libffi zlib zlib.dev zlib.out zlibStatic libpqxx gnupg lzma libxml2 
      ];
      config = {
        services.postgresql.enable = true;
        services.postgresql.package = pkgs.postgresql95;
      };
    }
  );

  containers.dotorg = (
    makeContainer {
      name = "dotorg";
      packages = with pkgs; [
        nodejs-8_x php php71Packages.composer yarn 
      ];
    }
  );

  containers.into-cms = (
    makeContainer {
      name = "into-cms";
      packages = with pkgs; [
        nodejs-8_x docker
      ];
    }
  );

  containers.ec-client = (
    makeContainer {
      name = "ec-client";
      packages = with pkgs; [
        nodejs-9_x
      ];
    }
  );

  containers.gn-into-test-integrations = (
    makeContainer {
      name = "gn-into-test-integrations";
      packages = with pkgs; [
        nodejs-9_x
      ];
    }
  );

  containers.gn-into-widget = (
    makeContainer {
      name = "gn-into-widget";
      packages = with pkgs; [
        python
        gnumake
        binutils
        gcc
        nodejs-6_x
      ];
    }
  );

  containers.colab-coop = (
    makeContainer {
      name ="colab-coop";
      packages = with pkgs; [
        nodejs-6_x
        compass
      ];
    }
  );

  containers.colab-coop-form-api = (
    makeContainer {
      name = "colab-coop-form-api";
      packages = with pkgs; [
        nodejs-6_x
      ];
    }
  );

  containers.sevgen-design-system = (
    makeContainer {
      name = "sevgen-design-system";
      packages = with pkgs; [
        python
        yarn
        nodejs-9_x
        php
        php71Packages.xdebug
        php71Packages.composer
        php71Packages.phpcs
      ];
    }
  );

  containers.sevgen-d8-cms = (
    makeContainer {
      name = "sevgen-d8-cms";
      packages = with pkgs; [
        yarn
        nodejs-9_x
        php
        php71Packages.xdebug
        php71Packages.composer
        php71Packages.phpcs
        drush
        mariadb
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
