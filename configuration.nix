# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./containers.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "brodavi-nixos"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  networking.useDHCP = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    git dhcp wget vim curl firefox chromium google-chrome tmux zsh oh-my-zsh pciutils atom gnome3.gnome_themes_standard zoom-us redshift-plasma-applet kdeApplications.kmix
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.

  # programs.bash.enableCompletion = true;
  programs.zsh.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    brodavi = {
      home = "/home/brodavi";
      extraGroups = ["wheel" "networkmanager"];
      isNormalUser = true;
      uid = 1000;
      shell = pkgs.zsh;
    };
    root = {
      shell = pkgs.zsh;
    };
  };

  # Extra config for zsh/oh-my-zsh
  programs.zsh.interactiveShellInit = ''
    export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh/

    # Customize your oh-my-zsh options here
    ZSH_THEME="agnoster"
    plugins=(git)

    source $ZSH/oh-my-zsh.sh
  '';

  programs.zsh.promptInit = ""; # Clear this to avoid a conflict with oh-my-zsh

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.03"; # Did you read the comment?
}
