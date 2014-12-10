#
# Cookbook Name:: wlpdemo
# Recipe:: default
#
# Copyright (C) 2014 Chef Software, Inc.
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

# XXX the wlp cookbook's default recipe will still try to go out over the Internet
# and download stuff... you may not want this if at a customer site
include_recipe 'wlp'

directory "/opt/webapps" do
  owner 'root'
  group node['root_group'] # warning: needs Chef 11+
  mode 00755
  recursive true
  action :create
end

cookbook_file "/opt/webapps/jenkins.war" do
  source 'http://mirrors.jenkins-ci.org/war-stable/latest/jenkins.war'
  owner 'root'
  group node['root_group']
  mode 00644
  action :create
end

wlp_server "jenkins" do
  config ({
            "featureManager" => {
              "feature" => [ "jsp-2.2", "servlet-3.0" ]
            },
            "httpEndpoint" => {
              "id" => "defaultHttpEndpoint",
              "host" => "*",
              "httpPort" => "${default.http.port}",
              "httpsPort" => "${default.https.port}"
            },
            "application" => {
              "id" => "jenkins",
              "name" => "jenkins",
              "type" => "war",
              "location" => "/opt/webapps/jenkins.war"
            }
          })
  jvmOptions [ "-Djava.net.ipv4=true" ]
  bootstrapProperties "default.http.port" => "9080", "default.https.port" => "9443"
  action [:create, :start]
end
