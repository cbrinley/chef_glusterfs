
lvm_volume_group "gluster_vg000" do
  physical_volumes node.glusterfs.physical_volumes 
  logical_volume 'glusterfs' do
  	size '100%VG'
	filesystem 'xfs'
	filesystem_options '-i size=512'
    mount_point :location => node.glusterfs.brick_path
    action :create
  end
  action :create
end

directory node.glusterfs.brick_path do
  recursive true
  action :create
end

mount node.glusterfs.brick_path do
  fstype "xfs"
  device "/dev/mapper/gluster_vg000-glusterfs"
  action [:mount, :enable]
end
