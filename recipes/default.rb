#
# Cookbook Name:: time_machine
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

package 'avahi' do
  package_name node['time_machine']['avahi_package']
end

include_recipe 'netatalk'

directory ::File.dirname(node['netatalk']['conf_file']) do
  recursive true
end

directory node['time_machine']['path'] do
  recursive true
end

template 'afp.conf' do
  source 'afp.conf.erb'
  path node['netatalk']['conf_file']
  notifies :restart, 'service[netatalk]', :immediately
end
