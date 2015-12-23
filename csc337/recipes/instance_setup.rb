#
# Cookbook Name:: csc337
# Recipe:: instance_setup
#
# Copyright (c) 2015, Arizona Board of Regents
# All rights reserved.
#
# This file is subject to the license terms in the LICENSE file found in the
# top-level directory of this distribution. No part of this project,
# including this file, may be copied, modified, propagated, or
# distributed except according to the terms contained in the LICENSE
# file.
#

# Installing PHP 5.6.x also installs Apache
package 'php56' do
  case node[:platform]
  when 'centos','redhat','fedora','amazon'
    package_name 'php56'
  when 'debian','ubuntu'
    package_name 'php5'
  end
  action :install
end

instance = search("aws_opsworks_instance", "self:true").first

# Assume instance is named for the netid of the user
netid = instance['hostname']

# Enable local user logins with passwords
execute "Enabling local user logins with passwords" do
  cwd "/etc/ssh/"
  command "sed -i.bak -e 's/PasswordAuthentication no/PasswordAuthentication yes/' sshd_config"
end

# Restart sshd service
service 'sshd' do
  action :restart
end

# Create local user
user netid do
  shell '/bin/bash'
end

# Change ownership of the default web directory
directory '/var/www/html' do
  owner netid
  group netid
  mode '0755'
  action :create
end

# Create a sym link into the user's home directory
execute "Creating html sym link" do
  cwd "/home/" + netid
  command "ln -s /var/www/html html"
end


