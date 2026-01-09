# Example: Install AUR packages using yay provider

include aur_yay

package { 'yay':
  ensure   => installed,
  provider => pacman,
}

package { 'google-chrome':
  ensure   => installed,
  provider => yay,
  require  => Package['yay'],
}
