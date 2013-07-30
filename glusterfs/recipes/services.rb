all_enabled = node.glusterfs.services.all.enabled
gfs_enabled = node.glusterfs.services.gluster.enabled
swf_enabled = node.glusterfs.services.swift.enabled

service "glusterd" do
	supports :status => true, :restart => true, :reload => true
	if all_enabled and gfs_enabled
		action [ :enable, :start ]
	else	
		action [ :enable, :stop ]
	end
end

service "gluster-swift-account" do
	supports :status => true, :restart => true, :reload => false
	if all_enabled and swf_enabled 
		action [ :enable, :start ]
	else	
		action [ :enable, :stop ]
	end
end

service "gluster-swift-container" do
	supports :status => true, :restart => true, :reload => false
	if all_enabled and swf_enabled 
		action [ :enable, :start ]
	else	
		action [ :enable, :stop ]
	end
end


service "gluster-swift-object" do
	supports :status => true, :restart => true, :reload => false
	if all_enabled and swf_enabled 
		action [ :enable, :start ]
	else	
		action [ :enable, :stop ]
	end
end

service "gluster-swift-proxy" do
	supports :status => true, :restart => true, :reload => false
	if all_enabled and swf_enabled 
		action [ :enable, :start ]
	else	
		action [ :enable, :stop ]
	end
end

