# puppet-aur-yay

Puppet package provider for Arch Linux AUR using yay.

## Description

This module provides a `yay` package provider for Puppet, allowing you to manage packages from both the official Arch Linux repositories and the Arch User Repository (AUR).

## Requirements

- Arch Linux
- yay must be installed on the system before using this provider
- Puppet 7+ or OpenVox 7+

### Installing yay

yay is available in the official Arch repos:

```bash
pacman -S yay
```

Or build from AUR manually (bootstrap):

```bash
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

## Usage

### Basic package installation

```puppet
package { 'google-chrome':
  ensure   => installed,
  provider => yay,
}
```

### Install specific version

```puppet
package { 'neovim':
  ensure   => '0.9.5-1',
  provider => yay,
}
```

### Keep package at latest version

```puppet
package { 'immich-server':
  ensure   => latest,
  provider => yay,
}
```

### Remove a package

```puppet
package { 'unwanted-package':
  ensure   => absent,
  provider => yay,
}
```

### Include the class (optional)

The class provides a warning if yay is not installed:

```puppet
include aur_yay
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
- Runs as root, which yay normally warns against. The provider uses `--noconfirm` for non-interactive operation.
- Only tested on Arch Linux

## License

Apache-2.0

## Contributing

Issues and pull requests welcome at https://github.com/tobixen/puppet-aur-yay
