{ config, lib, pkgs, ... }:

{
  containers.sevgen-design-system = {
    bindMounts = {
      "/home/brodavi/sevgen-design-system" = {
        hostPath = "/home/brodavi/shared/src/sevgen-design-system/";
        isReadOnly = false;
      };
    };

    config = {
      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.users = {
        brodavi = {
          home = "/home/brodavi";
          isNormalUser = true;
          uid = 1000;
        };
      };

      environment.systemPackages = with pkgs; [
        git
        vim
        yarn
        nodejs-8_x
        php
        php71Packages.xdebug
        php71Packages.composer
        php71Packages.phpcs
      ];
    };
  };

  containers.sevgen-d8-cms =
    {
      bindMounts = {
        "/home/brodavi/sevgen" = {
          hostPath = "/home/brodavi/shared/src/sevgen-d8-cms/";
          isReadOnly = false;
        };
      };

      config =
        { config, pkgs, ... }:
        {
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
                documentRoot = "/home/brodavi/sevgen/docroot";
                extraConfig = ''
                  DirectoryIndex index.php
                  <Directory "/home/brodavi/sevgen/docroot">
                    AllowOverride All
                  </Directory>
                '';
              }
            ];
          };

          networking.extraHosts = "
            127.0.0.1 localhost
            127.0.0.1 sevgen-d8.test
          ";

          # Define a user account. Don't forget to set a password with ‘passwd’.
          users.users = {
            brodavi = {
              home = "/home/brodavi";
              extraGroups = ["wheel" "wwwrun" "mysql"];
              isNormalUser = true;
              uid = 1000;
            };
          };

          # NOTE: must set settings.local.php host to 127.0.0.1
          services.mysql.enable = true;
          services.mysql.package = pkgs.mariadb;
          environment.systemPackages = with pkgs; [
            php
            php71Packages.xdebug
            php71Packages.composer
            php71Packages.phpcs
            mariadb
            yarn
            nodejs-9_x
            vim
          ];
        };
    };
}
