#!/bin/bash

ROOT=/root
LOGFILE="$ROOT/boostrap.log"


function main(){

  ####MAIN LOGIC BLOCKS

  log "Starting boostrap.sh"

  start_block "Init Checks"
  user_check
  check_point "user_check"
  end_block

  start_block "VIM Install"
  install_check "which vim" || yum_install vim
  end_block


  start_block "Ruby Repo Install"
  install_check "test -f /etc/yum.repos.d/rbel6.repo" || rpm_install http://rbel.frameos.org/rbel6
  end_block
  
  
  start_block "Ruby Install"
  install_check "test -f /usr/local/rvm/scripts/rvm" || rvm_install "1.9.3"
  end_block
  
  
  start_block "Gems Install"
  install_check 'test `gem -v` == "2.0.4"' || rvm_gems_install "2.0.4"
  end_block
  
  start_block "Configure Root profile with RVM"
  install_check "grep source ~/.bash_profile | grep scripts | grep rvm" || rvm_root_profile_config "1.9.3"
  end_block
  
  
  start_block "Chef Solo Install"
  install_check "gem list | grep chef" || chef_solo_install
  end_block
  
  
  start_block "Git Install"
  install_check "which git" || yum_install git
  end_block
  
  
  start_block "Chef_GlusterFS Git Repo Install"
  install_chef_glusterfs
  end_block


  start_block "LVM Git Repo Install"
  install_chef_lvm
  end_block
  

  start_block "System Chef Cookbooks Update"
  update_chef_system_cookbooks
  end_block
  
  
  start_block "SELinux Permissive"
  install_check 'test `getenforce` == "Permissive"' || set_selinux_permissive
  end_block

  start_block "Chef-Solo Run"
  test "$1" == "-b"
  install_check "test $? -eq 0" || run_chef_solo 
  end_block
  
  log "Bootstrap.sh complete."
}



####SUPPORTING FUNCTIONS 
function start_block(){
  log "--> [ BLOCK START ($1)]"
  cd $ROOT
  CURRENT_BLOCK="$1"
}

function log(){
  echo $1 | awk '{ print "["strftime()"]", $0; fflush() }' | tee -a $LOGFILE
}

function check_point(){
  if [ $? -ne 0 ]; then
    log "BLOCK: [$CURRENT_BLOCK] failed at line: $1"
    exit 1
  fi
}

function end_block(){
  if [ $? -ne 0 ]; then
    log "error occurred in block $CURRENT_BLOCK , exiting...."
    exit 1
  fi
  log "<-- [ BLOCK COMPLETE ($CURRENT_BLOCK)]"
  log ""
}

function install_check(){
  bash -c "$1" &>/dev/null
  local retcode=$?
  if [ $retcode -eq 0 ]; then
   log "[$CURRENT_BLOCK] already complete. Skipping install steps."
  fi
  return $retcode
}

function user_check(){
  if [ $UID -ne 0 ]; then
    log "this script must be run as root."
    return 1
  fi
}

function to_dir(){
  mkdir -p $1
  cd $1
}

function yum_install(){
  log "yum installing $1"
  yum -y install $1 &>/dev/null
}

function rpm_install(){
  log "rpm installing $1"
  rpm -Uvh $1 &>/dev/null
}

function git_install(){
  if [ -d $1 ]; then
    log "Updating exitsting GIT repo: $1"
    cd $1
    git pull &>/dev/null
  else
    log "Cloning GIT repo: $2"
    git clone $2 &>/dev/null
  fi
}

function rvm_install(){
  log "Installing RVM and Gems"
  curl -L https://get.rvm.io | bash -s stable --ruby >/dev/null
  check_point "curl -L https://geet.rvm.io"
  source /usr/local/rvm/scripts/rvm
  rvm install ruby $1 &>/dev/null
  rvm use ruby $1 &>/dev/null
}

function rvm_gems_install(){
  source /usr/local/rvm/scripts/rvm
  log "Installing Ruby Gems"
  rvm rubygems $1
  check_point "rvm rubygems $1"
}

function rvm_root_profile_config(){
  log "Configuring root profile with rvm $1"
  echo "source /usr/local/rvm/scripts/rvm" >> ~/.bash_profile
  echo "rvm use ruby $1" >> ~/.bash_profile
}

function chef_solo_install(){
  log "Installing chef-solo"
  gem install chef --no-ri --no-rdoc &>/dev/null
  check_point "gem install chef"
}

function install_chef_glusterfs(){
  to_dir src/chef
  git_install chef_glusterfs https://github.com/cbrinley/chef_glusterfs.git
  check_point "git_install chef_glusterfs https://github.com/cbrinley/chef_glusterfs.git"
}

function install_chef_lvm(){
  to_dir src/chef
  git_install lvm https://github.com/opscode-cookbooks/lvm.git
  check_point "git_install lvm https://github.com/opscode-cookbooks/lvm.git"
}

function update_chef_system_cookbooks(){
  to_dir /var/chef/cookbooks
  /bin/cp -r $ROOT/src/chef/chef_glusterfs/glusterfs .
  /bin/cp -r $ROOT/src/chef/lvm .
  check_point "update_chef_system_cookbooks"
}

function set_selinux_permissive(){
  log "Configuring SELinux with permissive setting"
  setenforce 0
  check_point "setenforce 0"
}


function run_chef_solo(){
  chef-solo -o glusterfs,lvm,glusterfs::lvm
}

#ACTUAL EXECUTION
main $@
