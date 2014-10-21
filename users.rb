# Local groups

gem_package "ruby-shadow" do  
  if node[:hostname] == "monitor03"
    gem_binary("/usr/bin/gem1.9.1")
  else
  end
  action :install
end

group "vuk"

group "fleetst" do
  gid 1015
end

group "ops" do
end

group "bamboo" do
end

# Local users

# set root password = saraza
user "root" do
  uid 0
  group "root"
  password = saraza
end

directory "/root/.ssh" do
  mode 0644
  owner "root"
end

cookbook_file "/root/.ssh/authorized_keys" do
  source "root_ssh_authorized_keys"
  path 
  mode 0644
  owner "root"
end

user "vuk" do
  group "vuk"
  password = saraza
  home node['vuk']['homedir']
  manage_home  true
  shell "/bin/bash"
  manage_home true
end

cookbook_file "/usr/local/vuk/.profile" do
  source "vuk_dot_profile"
  mode "0644"
end


user "mhalligan" do
  action :remove
  only_if "grep mhalligan /etc/passwd"
end

user "eric.weaver" do
  action :remove
  only_if "grep eric.weaver /etc/passwd"
end

group "eric.weaver" do
  action :remove
  only_if "grep eric.weaver /etc/group"
end

user "chefdev" do
  comment "Chef Development"
  uid 1010
  gid "users"
  home "/home/chefdev"
  shell "/bin/bash"
  password = saraza
  manage_home true
end

group "vukadmin" do
  gid 1011
end

user "vukadmin" do
  comment "Vuk Admin"
  uid 1011
  gid "vukadmin"
  home "/home/vukadmin"
  password = saraza
  shell "/bin/bash"
  manage_home true
end

user "fleetst" do
  uid 1015
  group "fleetst"
  home "/home/fleetst"
  password = saraza
  shell "/bin/bash"
  manage_home true
end

user "ops" do
  group "ops"
  home "/home/ops"
  shell "/bin/bash"
  password = saraza
  manage_home true
end

user "bamboo" do
  group "bamboo"
  home "/usr/local/bamboo"
  shell "/bin/bash"
  manage_home true
end

user "eric.koon" do 
  action :remove
  only_if "grep eric.koon /etc/passwd"
end

group "eric.koon" do
  action :remove
  only_if "grep eric.koon /etc/group"
end

user "paul.kim" do
  action :remove
  only_if "grep paul.kim /etc/passwd"
end

user "steve.reed" do
  action :remove
  only_if "grep steve.reed /etc/passwd"
end

user "jeff.mallett" do
  uid 2003
  group "vuk"
  home "/home/jeff.mallett"
  shell "/bin/bash"
  manage_home true
  password = saraza
end

user "ted.griggs" do
  uid 2004
  group "vuk"
  home "/home/ted.griggs"
  shell "/bin/bash"
  manage_home true
  password = saraza
end

user "john.smith" do
  uid 2005
  group "vuk"
  home "/home/john.smith"
  shell "/bin/bash"
  manage_home true
  password = saraza
end

user "gonzalo.arce" do
  uid 2006
  group "vuk"
  home "/home/gonzalo.arce"
  shell "/bin/bash"
  manage_home true
  password = saraza
end

user "kevin.binkley" do
  action :remove
  only_if "grep kevin.binkley /etc/passwd"
end

group "adm" do
  action :modify
  members ['vuk', 'jeff.mallett', 'ted.griggs', 'john.smith', 'fleetst', 'gonzalo.arce']
  append true
end

group "vukadmin" do
  gid 1011
  members ['fleetst']
  append true
end

remote_directory "/home/ted.griggs/.ssh" do
  owner "ted.griggs"
  group "root"
  mode  "0700"
  files_owner "ted.griggs"
  files_group "root"
  files_mode  "0400"
  source "ted.griggs_dotssh"
end

remote_directory "/home/fleetst/.ssh" do
  owner "fleetst"
  group "root"
  mode  "0700"
  files_owner "fleetst"
  files_group "root"
  files_mode  "0400"
  source "fleetst_dotssh"
end

remote_directory "/home/ops/.ssh" do
  owner "ops"
  group "root"
  mode  "0700"
  files_owner "ops"
  files_group "root"
  files_mode  "0400"
  source "fleetst_dotssh"
end

execute "ops_home_chmod" do
  not_if "ls -dl /home/ops | awk '{print $1}' | grep 'drwx------'"
  command "chmod 700 /home/ops"
end

