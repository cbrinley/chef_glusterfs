lvm_volume_group "gluster_vg000" do
  physical_volumes default.glusterfs.physical_volumes 
  logical_volume '' do
        size '100%VG'
        filesystem 'xfs'
        mount_point :location => default.glusterfs.brick_path, :options => 'size=512'
  end
end
