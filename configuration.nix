{ config, pkgs, ... }:

{
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # home-manager config
      ./home/matt.nix
      # Enable cachix for cached builds
      ./cachix.nix
    ];

  boot = {
    # additional WiFi driver options for stability
    extraModprobeConfig = ''
      options iwlwifi 11n_disable=1 swcrypto=1
    '';

    # Disable cgroups v2, breaks some docker images
    kernelParams = [ "systemd.unified_cgroup_hierarchy=0" ];
    loader = {
      efi = {
        canTouchEfiVariables = false;
        efiSysMountPoint = "/boot";
      };
      grub = {
        efiSupport = true;
        efiInstallAsRemovable = true;
        devices = [ "nodev" ];
        useOSProber = false;
        enable = true;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    nix-prefetch-github
    libnotify

    pinentry
    pinentry-curses

    openssl
    gnupg
    gnutls
    zlib
    readline
    zscroll
    zstd
    blueman
    bluez
    bluez-alsa
    bluez-tools

    alsa-lib
    cmake
    freetype
    expat
    pkg-config
    python3
    vulkan-validation-layers

    libpng
    libxkbcommon
    xsel
    xclip
    gnutar
    gzip
    gnumake
    gcc
    binutils
    coreutils
    gawk
    gnused
    gnugrep
    patchelf
    findutils
  ];

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
    #pulseaudio.enable = true;
    bluetooth.enable = true;

    # Prefer iGPU, disable discrete GPU by default
    nvidia.prime = {
      offload.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  i18n.defaultLocale = "en_US.UTF-8";

  services = {

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
   };

    openssh.enable = true;
    thermald.enable = true;
    tlp.enable = true;
    blueman.enable = true;

    pcscd.enable = true;

    xserver = {
      enable = true;
      layout = "us";
      videoDrivers = [ "nvidia" ];

      # Enable touchpad support (enabled default in most desktopManager).
      libinput = {
        enable = true;
        touchpad = {
          disableWhileTyping = true;
        };
      };

      desktopManager = {
        xterm.enable = false;
      };

      displayManager = {
        defaultSession = "none+i3";
      };

      windowManager.i3 = {
        enable = true;
        # package = pkgs.i3-gaps;
      };
    };

    # NOTE - included secrets, copy an ovpn profile here if needed
    # openvpn.servers = {
    #   new-admin-vpn = {
    #     autoStart = false;
    #     updateResolvConf = true;
    #     config = "config /etc/nixos/vpn/admin-vpn.ovpn";
    #   };
    # };
  };

    networking = {
      hostName = "irithyll";
      enableIPv6 = false;
      firewall.enable = false;
      networkmanager.insertNameservers = [ "192.168.1.1" "8.8.8.8" "8.8.4.4" ];
      useDHCP = false;
      interfaces.wlp0s20f3.useDHCP = true;

      wireless = {
        enable = true;
        userControlled.enable = true;
        networks.Bill_Wi_the_Science_Fi.pskRaw = "753dd4e939293158f5bafbd1192227dc6ba6a32819543a5a1da6cf6d44c385d9";
      };
    };

    nixpkgs = {
      config.allowUnfree = true;
    };

    security = {
    # for pipewire
    rtkit.enable = true;
    sudo.extraRules = [
      {
        users = [ "matt" ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };

  # sound.enable = true;

  time.timeZone = "America/New_York";

  users.users.matt = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  virtualisation.docker.enable = true;

  system.stateVersion = "21.11";
}
