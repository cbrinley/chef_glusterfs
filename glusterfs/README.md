glusterfs Cookbook
==================
Installs 3.3.2 gluster for centos 6.

Requirements
------------
Centos 6, the need for 3.3.2
LVM cookbook -> for creation of LVM volumes via chef this cookbook is required and associated gems: https://github.com/opscode-cookbooks/lvm

Attributes
----------
default['glusterfs']['physical_volumes'] -> array of physical volumes to be used with LVM group creation. used by lvm recipe
default['glusterfs']['brick_path'] -> specifies the mount point for the newly created lvm backed brick. used by lvm recipe

Usage
-----
#### glusterfs::default
include glusterfs in run_list

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[glusterfs]"
  ]
}
```

Contributing
------------
TODO: (optional) If this is a public cookbook, detail the process for contributing. If this is a private cookbook, remove this section.

e.g.
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
License: MIT
Authors: Chris Brinley
