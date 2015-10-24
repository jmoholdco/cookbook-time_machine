require 'spec_helper'
require 'shared_examples'

RSpec.describe 'test::two_volumes' do
  it_behaves_like 'any time_machine recipe'

  case os[:family]
  when 'redhat'
    describe file('/etc/netatalk/afp.conf') do
      it { is_expected.to exist }
      it { is_expected.to be_file }
      its(:content) { is_expected.to match(/\[one\]/) }
      its(:content) { is_expected.to match(/\[two\]/) }
    end
  when 'debian'
    describe file('/etc/netatalk/afp.conf'), if: os[:release].to_f >= 8.0 do
      it { is_expected.to exist }
      it { is_expected.to be_file }
      its(:content) { is_expected.to match(/\[one\]/) }
      its(:content) { is_expected.to match(/\[two\]/) }
    end
  when 'ubuntu'
    describe file('/usr/local/etc/afp.conf') do
      it { is_expected.to exist }
      it { is_expected.to be_file }
      its(:content) { is_expected.to match(/\[one\]/) }
      its(:content) { is_expected.to match(/\[two\]/) }
    end
  end
end
