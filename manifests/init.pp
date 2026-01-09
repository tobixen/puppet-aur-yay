# @summary Provides AUR package management via yay
#
# This class ensures yay is available on the system and sets up the required
# user and sudoers configuration for the yay provider to work.
#
# Yay must be installed manually or via another method before this module can
# manage AUR packages, as yay itself is an AUR package (chicken-and-egg problem).
#
# @param ensure
#   Whether yay should be present. Only 'present' is supported since
#   we cannot install yay via this module (it requires yay to install AUR packages).
#
# @param build_user
#   The user to run yay as. Defaults to '_yay'. This user will be created
#   as a system user with sudo access to pacman.
#
# @example Basic usage
#   include aur_yay
#
# @example Then use yay provider for packages (provider is set automatically)
#   package { 'immich-server':
#     ensure => installed,
#   }
#
class aur_yay (
  Enum['present'] $ensure     = 'present',
  String[1]       $build_user = '_yay',
) {
  # Set yay as the default package provider for this scope
  Package { provider => yay }

  # Create dedicated user for running yay/makepkg (cannot run as root)
  user { $build_user:
    ensure     => present,
    system     => true,
    home       => '/var/lib/yay',
    managehome => true,
    shell      => '/usr/bin/nologin',
    comment    => 'AUR package builder for Puppet',
  }

  # Grant the build user sudo access to pacman (required for installing built packages)
  file { '/etc/sudoers.d/yay-puppet':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    content => "# Managed by Puppet - aur_yay module\n${build_user} ALL=(root) NOPASSWD: /usr/bin/pacman\n",
  }

  # Check and warn if yay is not installed
  if $facts['aur_yay_available'] != true {
    notify { 'yay_not_installed':
      message  => 'yay is not installed. Install it manually: pacman -S yay (if in repos) or build from AUR',
      loglevel => warning,
    }
  }
}
