require 'puppet/provider/package'

Puppet::Type.type(:package).provide(:yay, parent: Puppet::Provider::Package) do
  desc "Package management using yay for Arch Linux AUR packages.

    This provider allows installing packages from both the official
    Arch repositories and the AUR using yay.

    Note: yay/makepkg cannot run as root, so this provider runs yay as
    a dedicated '_yay' user. Include the aur_yay class to set up this
    user and required sudoers configuration automatically.

    Example:
      include aur_yay

      package { 'immich-server':
        ensure => installed,
      }
  "

  confine operatingsystem: :archlinux

  has_feature :installable
  has_feature :uninstallable
  has_feature :upgradeable
  has_feature :versionable

  commands yay: 'yay'
  commands pacman: 'pacman'
  commands sudo: 'sudo'

  BUILD_USER = '_yay'.freeze

  # Run yay as dedicated build user since makepkg cannot run as root
  # The _yay user is created by the aur_yay class with home at /var/lib/yay
  def self.run_yay_as_build_user(*args)
    execute(
      [command(:sudo), '-u', BUILD_USER, '-H', command(:yay)] + args,
      failonfail: true,
      combine: true
    )
  end

  def run_yay_as_build_user(*args)
    self.class.run_yay_as_build_user(*args)
  end

  def self.instances
    packages = []

    # List all installed packages
    execpipe([command(:pacman), '-Q']) do |pipe|
      pipe.each_line do |line|
        if (match = line.match(/^(\S+)\s+(\S+)/))
          packages << new(
            name: match[1],
            ensure: match[2],
            provider: name
          )
        end
      end
    end

    packages
  end

  def query
    begin
      output = execute([command(:pacman), '-Q', @resource[:name]], failonfail: false)
      if output && (match = output.match(/^(\S+)\s+(\S+)/))
        { ensure: match[2], name: match[1] }
      else
        { ensure: :absent, name: @resource[:name] }
      end
    rescue Puppet::ExecutionFailure
      { ensure: :absent, name: @resource[:name] }
    end
  end

  def install
    # Use yay with --noconfirm for non-interactive installation
    # --needed skips reinstall if already installed at correct version
    args = ['--sync', '--noconfirm', '--needed']

    if @resource[:ensure].is_a?(String) && @resource[:ensure] != 'present' && @resource[:ensure] != 'latest'
      # Specific version requested
      args << "#{@resource[:name]}=#{@resource[:ensure]}"
    else
      args << @resource[:name]
    end

    run_yay_as_build_user(*args)
  end

  def update
    # Upgrade to latest version
    run_yay_as_build_user('--sync', '--noconfirm', @resource[:name])
  end

  def uninstall
    # Remove package and its dependencies that are no longer needed
    pacman('--remove', '--noconfirm', '--recursive', @resource[:name])
  end

  def latest
    # Query for latest available version
    begin
      output = run_yay_as_build_user('-Si', @resource[:name])
      if output && (match = output.match(/^Version\s*:\s*(\S+)/))
        match[1]
      else
        nil
      end
    rescue Puppet::ExecutionFailure
      nil
    end
  end
end
