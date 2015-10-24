require 'spec_helper'
require 'shared_examples'

RSpec.describe 'time_machine::default' do
  it_behaves_like 'any time_machine recipe'
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
