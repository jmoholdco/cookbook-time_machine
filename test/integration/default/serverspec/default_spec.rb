require 'spec_helper'

RSpec.describe 'time_machine::default' do
  describe command('/usr/sbin/afpd -V'), unless: os[:release].to_i == 14 do
    its(:exit_status) { is_expected.to eq 0 }
    its(:stdout) { is_expected.to match(/afpd 3\.[0-9]\.[0-9]/) }
  end

  describe command('/usr/local/sbin/afpd -V'), if: os[:release].to_i == 14 do
    its(:exit_status) { is_expected.to eq 0 }
    its(:stdout) { is_expected.to match(/afpd 3\.[0-9]\.[0-9]/) }
  end

  case os[:family]
  when 'redhat'
    describe file('/etc/netatalk/afp.conf') do
      it { is_expected.to exist }
      it { is_expected.to be_file }
      its(:content) { is_expected.to match(/\[Time Machine\]/) }
    end
  when 'debian'
    describe file('/etc/netatalk/afp.conf'), if: os[:release].to_f >= 8.0 do
      it { is_expected.to exist }
      it { is_expected.to be_file }
      its(:content) { is_expected.to match(/\[Time Machine\]/) }
    end
  when 'ubuntu'
    describe file('/usr/local/etc/afp.conf') do
      it { is_expected.to exist }
      it { is_expected.to be_file }
      its(:content) { is_expected.to match(/\[Time Machine\]/) }
    end
  end
end
