#LVM and storage related attributes
default["glusterfs"]["physical_volumes"] = ["/dev/xvdj"]
default["glusterfs"]["brick_path"] = "/data/gluster/brick1"

#Service related flags. Turn all services off with the all flag, or swift/gluster with respective subsets
default["glusterfs"]["services"]["all"]["enabled"] = true
default["glusterfs"]["services"]["swift"]["enabled"] = true
default["glusterfs"]["services"]["gluster"]["enabled"] = true

#peer / cluster related attributes
default["glusterfs"]["peers"] = ["server1","server2"] #example Change Me