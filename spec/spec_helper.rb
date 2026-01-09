require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |c|
  c.default_facts = {
    kernel: 'Linux',
    operatingsystem: 'Archlinux',
    osfamily: 'Archlinux',
    aur_yay_available: true,
    aur_yay_version: '12.0.0',
  }
end
