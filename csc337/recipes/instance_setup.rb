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

execute "Enable display errors by default" do
  cwd "/etc/"
  command "sed -i.bak -e 's/display_errors = Off/display_errors = On/' php.ini"
end

execute "Set timezone in php.ini" do
  cwd "/etc/"
  command "echo 'date.timezone = \"America/Phoenix\"' >> php.ini"
end

# MySQL
package 'mysql-server' do
  action :install
end

package 'php56-pdo' do
  action :install
end

package 'php56-mysqlnd' do
  action :install
end

# Start apache service
service 'httpd' do
  action :start
end

# Change permissions of the httpd logs directory
directory '/var/log/httpd' do
  mode '0755'
end

# Start mysql service
service 'mysqld' do
  action :start
end

# Grant privileges to localhost user
bash "Grant MySQL Privs to localhost user" do
    user "root"
    code <<-EOH
     mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO ''@'localhost'"
    EOH
end


# Grab the instance data for this instance from OpsWorks
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

# Create Home directory
directory '/home/' + netid do
  owner netid
  group netid
  mode '0755'
  action :create
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
  not_if { ::File.exists?("/home/" + netid + "/html") }
end

execute "Creating sym link to logs" do
  cwd "/home/" + netid
  command "ln -s /var/log/httpd logs"
  not_if { ::File.exists?("/home/" + netid + "/logs") }
end

# Create a placeholder index.html page
template "/var/www/html/index.php" do
  not_if { ::File.exists?("/var/www/html/index.php") }
  variables( :username => netid )
  source "index.php.erb"
  owner netid
  group netid
  mode 0644
end

