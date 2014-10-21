
# install jrockit jdk from local deb file

directory "/mnt/debs/" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

cookbook_file "/mnt/debs/jrockit-jdk_1.6.0-33-2_amd64.deb" do
  source "jrockit-jdk_1.6.0-33-2_amd64.deb"
  owner "root"
  mode "0644"
end

execute "install_jrockit" do
  not_if "dpkg -l jrockit-jdk | grep '^ii'"
  command "dpkg -i /mnt/debs/jrockit-jdk_1.6.0-33-2_amd64.deb"
end

# Create necessary symbolic links

["appletviewer", "apt", "extcheck", "idlj", "jar", "jarsigner", "java", "javac", "javadoc", "javah", "javap", "jconsole", "jdb", "jhat", "jps", "jrcmd", "jrmc", "jrunscript", "jstat", "jstatd", "keytool", "native2ascii", "orbd", "pack200", "policytool", "rmic", "rmid", "rmiregistry", "schemagen", "serialver", "servertool", "tnameserv", "tzinfo", "unpack200", "wsgen", "wsimport", "xjc"].each do |p|
  link "/etc/alternatives/#{p}" do
    to "/usr/local/jrockit-jdk1.6.0_33-R28.2.4-4.1.0/bin/#{p}"
  end
  
link "/usr/bin/#{p}" do
    to "/etc/alternatives/#{p}"
 end
end

# Tomcat installation

remote_file "/usr/local/apache-tomcat-7.0.52.tar.gz" do
  not_if "ls -l /usr/local/apache-tomcat-7.0.52"
  source "http://www.us.apache.org/dist/tomcat/tomcat-7/v7.0.52/bin/apache-tomcat-7.0.52.tar.gz"
  owner "ubuntu"
  group "ubuntu"
  mode "0755"
end

execute "install_tomcat7" do
  not_if "ls -l /usr/local/apache-tomcat-7.0.52"
  cwd "/usr/local"
  command "tar xzf apache-tomcat-7.0.52.tar.gz && chown -R ubuntu:ubuntu /usr/local/apache-tomcat-7.0.52"
end

link "/usr/local/tomcat" do
  not_if "ls -l /usr/local/tomcat"  
  to "/usr/local/apache-tomcat-7.0.52"
end
