# Fact: aur_yay_available
# Returns true if yay is installed and available

Facter.add(:aur_yay_available) do
  confine kernel: 'Linux'

  setcode do
    Facter::Util::Resolution.which('yay') ? true : false
  end
end

# Fact: aur_yay_version
# Returns the version of yay if installed

Facter.add(:aur_yay_version) do
  confine kernel: 'Linux'

  setcode do
    if Facter::Util::Resolution.which('yay')
      output = Facter::Util::Resolution.exec('yay --version 2>/dev/null')
      if output && (match = output.match(/yay\s+v?(\S+)/i))
        match[1]
      else
        nil
      end
    else
      nil
    end
  end
end
