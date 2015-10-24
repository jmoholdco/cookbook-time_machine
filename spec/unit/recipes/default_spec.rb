#
# Cookbook Name:: time_machine
# Spec:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

require 'spec_helper'

RSpec.shared_examples 'the default recipe' do
  let(:conf) { chef_run.node['netatalk']['conf_file'] }

  it 'includes the netatalk recipe' do
    expect(chef_run).to include_recipe 'netatalk'
  end

  it 'installs the package avahi' do
    expect(chef_run).to install_package 'avahi'
  end
end

RSpec.describe 'time_machine::default' do
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
          let(:opts) { { platform: platform, version: version } }
          include_examples 'converges successfully'
          it_behaves_like 'the default recipe'
        end
      end
    end
  end
end
