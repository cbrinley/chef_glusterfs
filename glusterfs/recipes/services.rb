all_enabled = node.glusterfs.services.all.enabled
gfs_enabled = node.glusterfs.services.gluster.enabled
swf_enabled = node.glusterfs.services.swift.enabled


log "Updating all service configuration files."
cookbook_file "/etc/swift/swift.conf" do
  source "swift.conf"
  mode 00644
end

cookbook_file "/etc/swift/fs.conf" do
  source "fs.conf"
  mode 00644
end

cookbook_file "/etc/swift/proxy-server.conf" do
  source "proxy-server.conf"
  mode 00644
end

cookbook_file "/etc/swift/account-server/1.conf" do
  source "account-server/1.conf"
  mode 00644
end

cookbook_file "/etc/swift/container-server/1.conf" do
  source "container-server/1.conf"
  mode 00644
end

cookbook_file "/etc/swift/object-server/1.conf" do
  source "object-server/1.conf"
  mode 00644
end

log "generating ring file"
/usr/bin/gluster-swift-gen-builders node.glusterfs.gluster_volume

log "ensuring all services have correct run state."
service "glusterd" do
	supports :status => true, :restart => true, :reload => true
	if all_enabled and gfs_enabled
		action [ :enable, :start ]
	else	
		action [ :disable, :stop ]
	end
end

service "memcached" do
	supports :status => true, :restart => true, :reload => true
	if all_enabled and swf_enabled
		action [ :enable, :start ]
	else	
		action [ :disable, :stop ]
	end
end


service "gluster-swift-account" do
	supports :status => true, :restart => true, :reload => false
	if all_enabled and swf_enabled 
		action [ :enable, :start ]
	else	
		action [ :disable, :stop ]
	end
end

service "gluster-swift-container" do
	supports :status => true, :restart => true, :reload => false
	if all_enabled and swf_enabled 
		action [ :enable, :start ]
	else	
		action [ :disable, :stop ]
	end
end


service "gluster-swift-object" do
	supports :status => true, :restart => true, :reload => false
	if all_enabled and swf_enabled 
		action [ :enable, :start ]
	else	
		action [ :disable, :stop ]
	end
end

service "gluster-swift-proxy" do
	supports :status => true, :restart => true, :reload => false
	if all_enabled and swf_enabled 
		action [ :enable, :start ]
	else	
		action [ :disable, :stop ]
	end
end

