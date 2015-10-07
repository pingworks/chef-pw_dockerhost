#
# Cookbook Name:: pw_dockerhost
# Recipe:: default
#
# Copyright (C) 2015 Christoph Lukas
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package 'apt-transport-https'

apt_repository 'docker' do
  uri 'https://apt.dockerproject.org/repo'
  distribution 'ubuntu-trusty'
  components ['main']
  keyserver 'keyserver.ubuntu.com'
  key '58118E89F3A912897C070ADBF76221572C52609D'
  action :add
end

package 'docker-engine'

service 'docker' do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
end

cookbook_file 'default-docker' do
  path '/etc/default/docker'
  mode '0600'
  owner 'root'
  group 'root'
  notifies :restart, 'service[docker]', :immediately
end
