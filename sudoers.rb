["vukadmin","chefdev"].each do |sudoer|
  sudoer1=sudoer.gsub(/\./,'_')
  sudo "#{sudoer1}_chef_client" do
    user sudoer
    commands ["/usr/local/bin/chef-client","/usr/local/bin/chef_server_backup.sh"]
    host "ALL"
    nopasswd true
  end
end

sudo "fleetst" do
  user "fleetst"
  commands ["/bin/su -"]
  host "ALL"
  nopasswd false
end
    
