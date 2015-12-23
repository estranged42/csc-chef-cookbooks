#
# Cookbook Name:: demo
# Recipe:: application_setup
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

# set up system

package 'apache2' do
  case node[:platform]
  when 'centos','redhat','fedora','amazon'
    package_name 'httpd'
  when 'debian','ubuntu'
    package_name 'apache2'
  end
  action :install
end
