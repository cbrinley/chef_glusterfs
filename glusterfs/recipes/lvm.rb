
lvm_volume_group "gluster_vg000" do
  physical_volumes node.glusterfs.physical_volumes 
  logical_volume 'glusterfs' do
        size '100%VG'
        filesystem 'xfs'
        mount_point :location => node.glusterfs.brick_path, :options => 'size=512'
  end
end
