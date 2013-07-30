default["glusterfs"]["physical_volumes"] = ["/dev/xvdj"]
default["glusterfs"]["brick_path"] = "/data/gluster/brick1"
default["glusterfs"]["services"]["all"]["enabled"] = true
default["glusterfs"]["services"]["swift"]["enabled"] = true
default["glusterfs"]["services"]["gluster"]["enabled"] = true
