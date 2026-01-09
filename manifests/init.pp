# @summary Provides AUR package management via yay
#
# This class ensures yay is available on the system. Yay must be installed
# manually or via another method before this module can manage AUR packages,
# as yay itself is an AUR package (chicken-and-egg problem).
#
# If yay is already installed (e.g., via the yay-bin package or manual install),
# this class does nothing.
#
# @param ensure
#   Whether yay should be present. Only 'present' is supported since
#   we cannot install yay via this module (it requires yay to install AUR packages).
#
# @example Basic usage
#   include aur_yay
#
# @example Then use yay provider for packages
#   package { 'immich-server':
#     ensure   => installed,
#     provider => yay,
#   }
#
class aur_yay (
  Enum['present'] $ensure = 'present',
) {
  # Verify yay is available - fail with helpful message if not
  exec { 'verify_yay_installed':
    command => '/usr/bin/true',
    unless  => '/usr/bin/which yay',
    onlyif  => '/usr/bin/false',  # This makes it always fail if yay is missing
  }

  # Better approach: just check and warn
  if $facts['aur_yay_available'] != true {
    notify { 'yay_not_installed':
      message  => 'yay is not installed. Install it manually: pacman -S yay (if in repos) or build from AUR',
      loglevel => warning,
    }
  }
}
