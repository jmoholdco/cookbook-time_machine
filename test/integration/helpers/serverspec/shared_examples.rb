RSpec.shared_examples 'any time_machine recipe' do
  describe command('/usr/local/sbin/afpd -V') do
    its(:exit_status) { is_expected.to eq 0 }
    its(:stdout) { is_expected.to match(/afpd 3\.[0-9]\.[0-9]/) }
  end
end
