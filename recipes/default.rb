#
# Cookbook Name:: rsyslog
# Recipe:: client
#
# Copyright 2009-2011, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "rsyslog::client"

unless node['rsyslog']['server'] 
  if node['rsyslog']['logstash_server'].nil?
    logstash_server = search(:node, "role:log-server").first['hostname'] rescue nil
  else
    logstash_server = node['rsyslog']['logstash_server']
  end
end

template "/etc/rsyslog.d/91-logstash.conf" do
  source "91-logstash.conf.erb"
  backup false
  variables(
    :server => logstash_server,
    :protocol => node['rsyslog']['protocol']
  )
  owner "root"
  group "root"
  mode 0644
  not_if { logstash_server.nil? }
  notifies :restart, "service[rsyslog]", :immediately
end
