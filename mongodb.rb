execute "apt-key-10gen" do
  not_if "apt-key list | grep richard@10gen.com"
  command "apt-key adv --keyserver keyserver.ubuntu.com --recv 9ECBEC467F0CEB10"
end

execute "apt-key-opscode" do
  not_if "apt-key list | grep packages@opscode.com"
  command "apt-key adv --keyserver keyserver.ubuntu.com --recv 2940ABA983EF826A"
end

apt_repository "10gen" do
  uri		"http://downloads-distro.mongodb.org/repo/ubuntu-upstart"
  components	["dist", "10gen"]
end

package "mongodb18-10gen" do
  not_if	"dpkg -l 'mongo*' | grep '^ii'"
  #version "1.8.5"
  options  "--force-yes"
end

mongodb_options = node['mongo-no-repl'] ? '' : ' --replSet gokoSet'
file "/etc/default/mongodb" do
   owner "root"
   mode "0655"
   content "
ENABLE_MONGODB=yes
mongodb_options='#{mongodb_options}'
"
end

cookbook_file "/etc/init/mongodb.conf" do
    owner "root"
end

template "/etc/mongodb.conf" do
    owner "root"
    mode "0644"
    source "etc_mongodb.conf"
    variables(	:no_repl => node['mongo-no-repl'],
		:bind_local => node['mongo-bind-localhost']
	)
end


file "/var/lib/mongodb/mongod.lock" do
    action	:delete
    only_if	"[ -e /var/lib/mongodb/mongod.lock ]"
end

# supplanted by making /etc/mongodb.conf a template
#if node.attribute?('mongo-bind-localhost') 
#  execute "mongodb-bind" do
#      not_if	"grep '^[^#]*bind_ip=127.0.0.1' /etc/mongodb.conf"
#      command	"echo 'bind_ip=127.0.0.1' >> /etc/mongodb.conf"
#  end
#end

#  Just make sure it's active on boot
service "mongodb" do
    case node[:platform]
    when "ubuntu"
      if node[:platform_version].to_f >= 9.10
        provider Chef::Provider::Service::Upstart
      end
    end
    action [:enable, :start]
end

if node['mongo-boot-cleaned-out'] == false 
  execute "mogodb-drop" do
      command "sleep 5; /usr/bin/mongo << EOF
    use vukrelease;
    db.dropDatabase();
EOF
"
  end
  node.normal['mongo-boot-cleaned-out'] = true
  node.save
end

#include_recipe("funsockets::firewall")

user "backup" do
end

directory "/var/backups/.ssh" do
  mode "0700"
  owner "backup"
end


cookbook_file "/var/backups/.ssh/authorized_keys" do
  source "backup_user_authkeys"
  mode "0400"
  owner "backup"
end

cron "mongo_logrotate" do 
  minute 0
  hour 0
  mailto "operations@funsockets.com" 
  user "mongodb"
  command '/usr/bin/mongo --eval "db.getMongo().getDB(\"admin\").runCommand(\"logRotate\")" 1> /var/tmp/mongodb.logrotate.out'
end

cookbook_file "/etc/security/limits.conf" do
  source "etc_security_limits.conf"
  owner "root"
  mode  "0644"
end

# Adding specific stuff for munin monitoring only on *-mongodb01
if node[:hostname] == "staging-mongodb01"
	remote_directory "/etc/munin/plugins" do
		source "mongo_munin_goodies"
		files_owner "root"
		files_group "root"
		files_mode "755"
		owner "root"
		group "root"
		mode "755"
		notifies :restart, "service[munin-node]"
	end
end
if node[:hostname] == "prod-mongodb01"
        remote_directory "/etc/munin/plugins" do
                source "mongo_munin_goodies"
                files_owner "root"
                files_group "root"
                files_mode "755"
                owner "root"
                group "root"
                mode "755"
                notifies :restart, "service[munin-node]"
        end
end
if node[:hostname] == "prod-mongodb02"
        remote_directory "/etc/munin/plugins" do
                source "mongo_munin_goodies"
                files_owner "root"
                files_group "root"
                files_mode "755"
                owner "root"
                group "root"
                mode "755"
                notifies :restart, "service[munin-node]"
        end
end
if node[:hostname] == "prod-mongodb03"
        remote_directory "/etc/munin/plugins" do
                source "mongo_munin_goodies"
                files_owner "root"
                files_group "root"
                files_mode "755"
                owner "root"
                group "root"
                mode "755"
                notifies :restart, "service[munin-node]"
        end
end


