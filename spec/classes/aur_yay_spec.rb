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

    it {
      is_expected.to contain_user('_yay').with(
        ensure: 'present',
        system: true,
        home: '/var/lib/yay',
        shell: '/usr/bin/nologin',
      )
    }

    it {
      is_expected.to contain_file('/etc/sudoers.d/yay-puppet').with(
        ensure: 'file',
        owner: 'root',
        group: 'root',
        mode: '0440',
      ).with_content(%r{_yay ALL=\(root\) NOPASSWD: /usr/bin/pacman})
    }
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
    it { is_expected.to contain_user('_yay') }
    it { is_expected.to contain_file('/etc/sudoers.d/yay-puppet') }
  end

  context 'with custom build_user' do
    let(:facts) do
      {
        kernel: 'Linux',
        operatingsystem: 'Archlinux',
        osfamily: 'Archlinux',
        aur_yay_available: true,
        aur_yay_version: '12.0.0',
      }
    end
    let(:params) { { build_user: 'aur_builder' } }

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_user('aur_builder') }

    it {
      is_expected.to contain_file('/etc/sudoers.d/yay-puppet')
        .with_content(%r{aur_builder ALL=\(root\) NOPASSWD: /usr/bin/pacman})
    }
  end
end
