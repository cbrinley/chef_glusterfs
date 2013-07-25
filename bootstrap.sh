#!/bin/bash

ROOT=/root
LOGFILE="$ROOT/bootstrap.log"
SCRIPT_ARGS="$@"
EXIT_SCRIPT=0
SCRIPT_PATH=$0
IGNORE_RET_CODE=0



function main(){

  ####MAIN LOGIC BLOCKS
  has_option h && (show_help; exit)  
  has_option s && no_output

  log "Starting bootstrap.sh"

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

  start_block "Update Bootstrap"
  has_option u && update_bootstrap
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
  has_no_option b && run_chef_solo
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

function no_output(){
  exec >&-
}

function set_exit(){
  EXIT_MSG="$1"
  EXIT_SCRIPT=1
}

function clear_exit(){
  EXIT_MSG=""
  EXIT_SCRIPT=0
}

function check_exit(){
  test $EXIT_SCRIPT -ne 0 && return 0 || return 1
}

function ignore_ret_code(){
  IGNORE_RET_CODE=1
}

function clear_ignore_ret_code(){
  IGNORE_RET_CODE=0
}

function check_ignore_ret_code(){
  test $IGNORE_RET_CODE -ne 0 && return 0 || return 1
}

function check_point(){
  if [ $? -ne 0 ]; then
    log "BLOCK: [$CURRENT_BLOCK] failed at line: $1"
    exit 1
  fi
}

function end_block(){
  if [ $? -ne 0 ]; then
    check_ignore_ret_code
    if [ $? -ne 0 ]; then
      log "error occurred in block $CURRENT_BLOCK , exiting...."
      exit 1
    fi
  fi 
  clear_ignore_ret_code
  check_exit
  if [ $? -eq 0 ]; then
    log "Exiting: $EXIT_MSG"
    log "<-- [ BLOCK EXIT ($CURRENT_BLOCK)]"
    exit 0
  else
    log "<-- [ BLOCK COMPLETE ($CURRENT_BLOCK)]"
    log ""
  fi
}

function install_check(){
  bash -c "$1" &>/dev/null
  local retcode=$?
  if [ $retcode -eq 0 ]; then
   log "[$CURRENT_BLOCK] already complete. Skipping install steps."
  fi
  return $retcode
}

function has_option(){
  OPTIND=1
  ignore_ret_code
  local retcode=1
  while getopts "$1" OPTION $SCRIPT_ARGS &>/dev/null
  do
    case $OPTION in
      $1) retcode=0
          break
          ;;
       ?) continue
          ;;
    esac
  done
  return $retcode
}

function has_no_option(){
  has_option $1
  test $? -eq 0 && return 1 || return 0
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

function update_bootstrap(){
  /bin/cp $ROOT/src/chef/chef_glusterfs/bootstrap.sh $SCRIPT_PATH
  set_exit "bootstrap.sh is up to date."
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

function show_help(){
  set_exit "User requested help message."
  cat <<EOF

  Help: bootstrap.sh [options]
    -h this Help
    -u update this script. will take effect on next run. script exits after update.
    -b only run bootstrap code. do not run chef recipes.
    -s silent. no log messages are sent to screen.

EOF
}
#ACTUAL EXECUTION
main $@
