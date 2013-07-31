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


def make_peer!
    peer_name = new_resource.name
    mk_cmd = Mixlib::ShellOut.new "gluster peer probe #{peer_name} 2>&1"
    mk_cmd.run_command
    Chef::Log.info mk_cmd.stdout
    mk_cmd.error!
    new_resource.updated_by_last_action(true)
end


def delete_peer!
    peer_name = new_resource.name
    del_cmd = Mixlib::ShellOut.new "gluster peer detach #{peer_name} 2>&1"
    del_cmd.run_command
    Chef:Log.info del_cmd.stdout
    del_cmd.error!
    new_resource.updated_by_last_action(true)
end


def can_run?
    if is_self(new_resource.name) then
        Chef::Log.info "Cannot peer with self. Skipping peer #{new_resource.name}"
        return false
    end
    if not gluster_running then
        Chef::Log.info "Gluster not running peer #{new_resource.name} can not be created."  
        return false
    end
    return true
end


def do_create
    if peer_exists new_resource.name then 
        Chef::Log.info "Gluster Peer #{new_resource.name} already exists - nothing to do."
    else
        make_peer!
    end
end


def do_delete
    if not peer_exists new_resource.name then 
        Chef::Log.info "Gluster Peer #{new_resource.name} does not exists - nothing to do."
    else
        delete_peer!
    end   
end


action :create do
    if can_run? then do_create end 
end

action :delete do 
    if can_run? then do_delete end
end

