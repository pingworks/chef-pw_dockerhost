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

bash 'install nsenter' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
  docker pull jpetazzo/nsenter
  docker run --rm -v /usr/local/bin:/target jpetazzo/nsenter
  docker rmi jpetazzo/nsenter
  EOH
  not_if 'test -x /usr/local/bin/nsenter'
end

cookbook_file '/usr/local/bin/docker-mount.sh' do
  source 'docker-mount.sh'
  owner 'root'
  group 'root'
  mode 00755
  not_if 'test -x /usr/local/bin/docker-mount.sh'
end
