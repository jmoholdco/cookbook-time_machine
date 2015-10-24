#
# Cookbook Name:: time_machine
# Recipe:: volumes
#
# The MIT License (MIT)
#
# Copyright (c) 2015 J. Morgan Lieberthal
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

include_recipe 'chef-sugar::default'
gem_package 'chef_helpers'
chef_gem 'chef_helpers'
require_chef_gem 'chef_helpers'
extend ChefHelpers

include_recipe 'chef-vault'
include_recipe 'time_machine::default'

staff_group_name = value_for_platform_family(
  'debian' => 'dialout',
  'rhel' => 'games'
)

group staff_group_name do
  gid '20'
  action :remove
end

group 'staff' do
  gid '20'
  action [:create, :manage]
end

raw_password = chef_vault_item('passwords', 'morgan')
shadow_hash = encrypt_password(raw_password['password'])

user 'morgan' do
  comment 'J. Morgan Lieberthal'
  uid 501
  gid 20
  home '/home/morgan'
  shell '/bin/zsh'
  manage_home true
  password shadow_hash
end

time_machine_volume 'TimeMachine' do
  path '/srv/time_machine'
  allowed_users %w(morgan)
  allowed_user_group 'timemachine'
end

directory '/srv/time_machine' do
  recursive true
  owner 'morgan'
  group 'staff'
  mode '0755'
end
