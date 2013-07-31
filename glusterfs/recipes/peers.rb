node.glusterfs.peers do |peer_name|
	peer peer_name do 
		action :create
	end
end