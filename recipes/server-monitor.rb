#
# Cookbook Name:: newrelic
# Recipe:: server-monitor
#
# Copyright 2012-2013, Escape Studios
#

#install the server monitor
case node['platform']
    when "debian", "ubuntu", "redhat", "centos", "fedora", "scientific", "amazon"
        package "newrelic-sysmond" do
            action :install
        end

        #configure your New Relic license key
        template "/etc/newrelic/nrsysmond.cfg" do
            source "nrsysmond.cfg.erb"
            owner "root"
            group "newrelic"
            mode "640"
            variables(
                :license => node['newrelic']['server_monitoring']['license'],
                :logfile => node['newrelic']['server_monitoring']['logfile'],
                :loglevel => node['newrelic']['server_monitoring']['loglevel'],
                :proxy => node['newrelic']['server_monitoring']['proxy'],
                :ssl => node['newrelic']['server_monitoring']['ssl'],
                :ssl_ca_path => node['newrelic']['server_monitoring']['ssl_ca_path'],
                :ssl_ca_bundle => node['newrelic']['server_monitoring']['ssl_ca_bundle'],
                :pidfile => node['newrelic']['server_monitoring']['pidfile'],
                :collector_host => node['newrelic']['server_monitoring']['collector_host'],
                :timeout => node['newrelic']['server_monitoring']['timeout']
            )
            notifies :restart, "service[newrelic-sysmond]"
        end
  when "windows"
    include_recipe "ms_dotnet4"

    if node['kernel']['machine'] == "x86_64"
        windows_package "New Relic Server Monitor" do
            source "http://download.newrelic.com/windows_server_monitor/release/NewRelicServerMonitor_x64_#{node['newrelic']['server_monitoring']['windows_version']}.msi"
            options "/L*v install.log /qn NR_LICENSE_KEY=#{node['newrelic']['server_monitoring']['license']}"
            action :install
            version node['newrelic']['server_monitoring']['windows_version']
            checksum node['newrelic']['server_monitoring']['windows64_checksum']
        end
    else
        windows_package "New Relic Server Monitor" do
            source "http://download.newrelic.com/windows_server_monitor/release/NewRelicServerMonitor_x86_#{node['newrelic']['server_monitoring']['windows_version']}.msi"
            options "/L*v install.log /qn NR_LICENSE_KEY=#{node['newrelic']['server_monitoring']['license']}"
            action :install
            version node['newrelic']['server_monitoring']['windows_version']
            checksum node['newrelic']['server_monitoring']['windows32_checksum']
        end
    end
end

service "newrelic-sysmond" do
    supports :status => true, :start => true, :stop => true, :restart => true
    action [:enable, :start] #starts the service if it's not running and enables it to start at system boot time
end