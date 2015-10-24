require 'spec_helper'

RSpec.shared_examples 'lwrp_time_machine' do
  let(:conf) { chef_run.node['netatalk']['conf_file'] }

  it 'includes the netatalk recipe' do
    expect(chef_run).to include_recipe 'netatalk'
  end

  it 'installs the package avahi' do
    expect(chef_run).to install_package 'avahi'
  end

  it 'sets the config options in the nodes attributes' do
    expect(chef_run.node['time_machine']['volumes']).to_not be_nil
    config = chef_run.node['time_machine']['volumes'].map { |n| n[:name] }
    expect(config).to include('Time Machine')
  end

  it 'creates the path for the volume' do
    expect(chef_run).to create_directory('/srv/time_machine')
  end

  describe 'the config template' do
    let(:afp_conf) { chef_run.template('afp.conf') }

    it 'does nothing by default, but is a part of the chef run' do
      expect(afp_conf).to do_nothing
    end
  end
end

RSpec.describe 'test::default' do
  let(:chef_run) { ChefSpec::SoloRunner.new(opts).converge(described_recipe) }
  context 'When all attributes are default' do
    supported_platforms = {
      'ubuntu' => %w(14.04 15.10),
      'centos' => %w(7.0 7.1.1503),
      'debian' => %w(7.8 8.0 8.1)
    }

    supported_platforms.each do |platform, versions|
      versions.each do |version|
        context "on #{platform} v#{version}" do
          let(:opts) do
            {
              platform: platform,
              version: version,
              step_into: ['time_machine_volume']
            }
          end
          include_examples 'converges successfully'
          it_behaves_like 'lwrp_time_machine'
        end
      end
    end
  end
end
