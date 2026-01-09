# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.1] - 2026-01-09

### Fixed

- CI workflow for Puppet Forge publishing

## [0.1.0] - 2026-01-09

### Added

- Initial release of the `yay` package provider for Puppet
- Support for installing packages from official Arch repositories and AUR
- Package provider features: installable, uninstallable, upgradeable, versionable
- Custom facts: `aur_yay_available` and `aur_yay_version`
- `aur_yay` class that sets up:
  - Dedicated `_yay` system user for building AUR packages
  - Sudoers configuration for pacman access
  - `yay` as the default package provider
- GitHub Actions CI for spec testing (Puppet 7 and 8)
- GitHub Actions workflow for automatic Puppet Forge publishing
