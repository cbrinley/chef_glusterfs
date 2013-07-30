def initialize *args
    super
    require 'mixlib/shellout'
    require 'socket'

end


def is_self(peer_name)
    if peer_name == Socket.gethostname then return true end
    addrs = []
    Socket.ip_address_list.each do |addr|
        addr.push addr.ip_address
    end
    return addrs.include? peer_name 
end


def peer_exists(peer_name)
    gpeer = Mixlib::ShellOut.new "gluster peer status 2>&1 | grep #{peer_name}"
    gpeer.run_command
    return (not gpeer.stdout.empty?)
end


def gluster_running
    gfs_stat = Mixlib::ShellOut.new "/etc/init.d/glusterd status | grep running"
    gfs_stat.run_command
    if gfs_stat.exitstatus != 0 then return false end
end


def mk_peer(peer_name)
    mkpeer = Mixlib::ShellOut.new "gluster peer probe #{peer_name} 2>&1"
    mkpeer.run_command
    Chef::Log.info mkpeer.stdout
    if mkpeer.exitstatus != 0 then return false end
    return true
end


def del_peer(peer_name)
    delpeer = Mixlib::ShellOut.new "gluster peer detach #{peer_name} 2>&1"
    delpeer.run_command
    Chef:Log.info delpeer.stdout
    if delpeer.exitstatus != 0 then return false end
    return true
end


def do_create
    if is_self(new_resource.name) then
        Chef::Log.info "Cannot peer with self. Skipping peer #{new_resource.name}"
        return true
    end
    if not gluster_running then
        Chef::Log.info "Gluster not running peer #{new_resource.name} can not be created."  
        return false
    end
    if peer_exists new_resource.name then 
        Chef::Log.info "Gluster Peer #{new_resource.name} already exists - nothing to do."
        return true
    else
        return mkpeer new_resource.name
    end
end


def do_delete
    if is_self(new_resource.name) then
        Chef::Log.info "Cannot peer with self. Skipping peer #{new_resource.name}"
        return true
    end
    if not gluster_running then
        Chef::Log.info "Gluster not running peer #{new_resource.name} can not be created."  
        return false
    end
    if not peer_exists new_resource.name then 
        Chef::Log.info "Gluster Peer #{new_resource.name} does not exists - nothing to do."
        return true
    else
        return delpeer
    end   
end


action :create do
    do_create 
end

action :delete do 
    do_delete
end

