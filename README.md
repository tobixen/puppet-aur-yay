# puppet-aur-yay

Puppet package provider for Arch Linux AUR using yay.

## Disclaimer

Everything in this package, except for this disclaimer has been vibed up utilizing Claude Code.

## Description

This module provides a `yay` package provider for Puppet, allowing you to manage packages from both the official Arch Linux repositories and the Arch User Repository (AUR).

## Requirements

- Arch Linux
- yay must be installed on the system before using this provider
- Puppet 7+ or OpenVox 7+

## Setup

Include the `aur_yay` class to set up the required user and sudoers configuration:

```puppet
include aur_yay
```

This creates:
- A `_yay` system user for running yay/makepkg (cannot run as root)
- A sudoers file (`/etc/sudoers.d/yay-puppet`) granting the user access to pacman
- Sets `yay` as the default package provider (no need to specify `provider => yay`)

### Installing yay

Build from AUR manually (bootstrap):

```bash
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

## Usage

First, include the class to set up the yay provider:

```puppet
include aur_yay
```

### Basic package installation

```puppet
package { 'google-chrome':
  ensure => installed,
}
```

### Install specific version

```puppet
package { 'neovim':
  ensure => '0.9.5-1',
}
```

### Keep package at latest version

```puppet
package { 'immich-server':
  ensure => latest,
}
```

### Remove a package

```puppet
package { 'unwanted-package':
  ensure => absent,
}
```

## Facts

This module provides the following facts:

- `aur_yay_available` - Boolean, true if yay is installed
- `aur_yay_version` - String, version of yay if installed

## Provider Features

| Feature       | Supported |
|---------------|-----------|
| installable   | Yes       |
| uninstallable | Yes       |
| upgradeable   | Yes       |
| versionable   | Yes       |

## Limitations

- yay must be pre-installed (chicken-and-egg: can't use AUR provider to install AUR helper)
- The `aur_yay` class must be included to set up the `_yay` build user before using the provider
- Only tested on Arch Linux

## License

Apache-2.0

## Contributing

Issues and pull requests welcome at https://github.com/tobixen/puppet-aur-yay
