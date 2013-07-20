#!/bin/bash
#Sets up various aliases that are helpful for working with these cookbooks interactively
function upcb(){
  /bin/cp -r /root/src/chef/chef_glusterfs/* /var/chef/cookbooks/.
  echo "cookbooks updated"
}

alias solo=chef-solo
