glusterfs Cookbook
==================
Installs 3.3.2 gluster for centos 6.

Requirements
------------
Centos 6, the need for 3.3.2

Attributes
----------
None currently

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
