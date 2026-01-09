require 'spec_helper'

describe 'aur_yay' do
  context 'with yay available' do
    let(:facts) do
      {
        kernel: 'Linux',
        operatingsystem: 'Archlinux',
        osfamily: 'Archlinux',
        aur_yay_available: true,
        aur_yay_version: '12.0.0',
      }
    end

    it { is_expected.to compile.with_all_deps }
    it { is_expected.not_to contain_notify('yay_not_installed') }
  end

  context 'with yay not available' do
    let(:facts) do
      {
        kernel: 'Linux',
        operatingsystem: 'Archlinux',
        osfamily: 'Archlinux',
        aur_yay_available: false,
        aur_yay_version: nil,
      }
    end

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_notify('yay_not_installed') }
  end
end
