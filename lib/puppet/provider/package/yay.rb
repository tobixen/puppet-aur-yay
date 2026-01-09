require 'puppet/provider/package'

Puppet::Type.type(:package).provide(:yay, parent: Puppet::Provider::Package) do
  desc "Package management using yay for Arch Linux AUR packages.

    This provider allows installing packages from both the official
    Arch repositories and the AUR using yay.

    Example:
      package { 'immich-server':
        ensure   => installed,
        provider => yay,
      }
  "

  confine operatingsystem: :archlinux
  defaultfor operatingsystem: :archlinux

  has_feature :installable
  has_feature :uninstallable
  has_feature :upgradeable
  has_feature :versionable

  commands yay: 'yay'
  commands pacman: 'pacman'

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

    yay(*args)
  end

  def update
    # Upgrade to latest version
    yay('--sync', '--noconfirm', @resource[:name])
  end

  def uninstall
    # Remove package and its dependencies that are no longer needed
    pacman('--remove', '--noconfirm', '--recursive', @resource[:name])
  end

  def latest
    # Query for latest available version
    begin
      output = execute([command(:yay), '-Si', @resource[:name]], failonfail: false)
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
