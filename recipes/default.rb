#
# Cookbook Name:: time_machine
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

package 'avahi' do
  package_name node['time_machine']['avahi_package']
end

include_recipe 'netatalk'

template 'afp.conf' do
  source 'afp.conf.erb'
  owner 'root'
  group node['root_group']
  path node['netatalk']['conf_file']
  mode '0644'
  helpers TimeMachineCookbook::TemplateHelpers
  variables lazy { { volumes: node.run_state['time_machine_volumes'] } }
  action :nothing
  notifies :restart, 'service[netatalk]', :immediately
end
