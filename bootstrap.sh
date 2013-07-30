#!/bin/bash

ROOT=/root
LOGFILE="$ROOT/bootstrap.log"
SCRIPT_ARGS="$@"
EXIT_SCRIPT=0
SCRIPT_PATH=$0
IGNORE_RET_CODE=0



function main(){

  ####MAIN LOGIC BLOCKS
  has_option h && show_help
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

  start_block "Chef Run"
  has_no_option b && recipes "glusterfs,lvm,glusterfs::lvm,glusterfs::services"
  end_block
  
  log "Bootstrap.sh complete."
}



####SUPPORTING FUNCTIONS 
function start_block(){
  #Doc:  Use start_block to being a logical processing and logging section.
  #Arg1: Name of the logical block
  #Ret:  Null
  #
  log "--> [ BLOCK START ($1)]"
  cd $ROOT
  CURRENT_BLOCK="$1"
}

function log(){
  #Doc:  Log statements to screen and disk.
  #Arg1: Message to log
  #Ret:  Null
  #
  echo $1 | awk '{ print "["strftime()"]", $0; fflush() }' | tee -a $LOGFILE
}

function no_output(){
  #Doc:  Nulls all output of this script. Including any subprocesses.
  #Ret:  Null
  #
  exec 1>/dev/null
  exec 2>/dev/null
}

function set_exit(){
  #Doc:  Sets a flag that instructs the end_block statement to exit the script but without error.
  #Arg1: A message that will be logged with the exit action.  
  #Ret:  Null
  #
  EXIT_MSG="$1"
  EXIT_SCRIPT=1
}

function clear_exit(){
  #Doc: Clears the flag that may have been set by set_exit. Aka cancel any pending exit.
  #Ret: Null
  #
  EXIT_MSG=""
  EXIT_SCRIPT=0
}

function check_exit(){
  #Doc: Check if exit flag is currently set
  #Ret: Returns 0 if flag is set else 1.
  test $EXIT_SCRIPT -ne 0 && return 0 || return 1
}

function ignore_ret_code(){
  #Doc: Some functions return a non-zero code to indicate a "no" answer to some state check. This does not mean failure.
  #Doc: This function sets a flag that tells the end_block function to ignore any pending $? == 1. Only required if the
  #Doc: last call before end_block may result in a non-zero ret code that does not indicate failure. It is responsibility
  #Doc: of the funciton to decide if a ignore_ret_code is required. The calling code should not normally address this.
  #Ret: Null
  # 
  IGNORE_RET_CODE=1
}

function clear_ignore_ret_code(){
  #Doc: Clears the flag set by ignore_ret_code
  #Ret: Null
  #
  IGNORE_RET_CODE=0
}

function check_ignore_ret_code(){
  #Doc: Checks if the ignore_ret_code flag is set. Note this function its self may return 1 which should not be
  #Doc: considered an error. Use with care near end_block calls.
  #Ret: Returns 0 if set 1 if not set.
  #
  test $IGNORE_RET_CODE -ne 0 && return 0 || return 1
}

function check_point(){
  #Doc:  to be used after a call that may fail and for which continuation could lead to un-predictable state. When
  #Doc:  called if the previous call exited with non-zero return code check_point will exit the script printing some
  #Doc:  debug info about current block and a caller chosen message.
  #Arg1: This arg should indicate where script failed. Usually use a string repr of the line that failed.
  #Ret:  1 if $? was not 0. Also exits the script.
  #
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
          clear_ignore_ret_code
          break
          ;;
       ?) continue
          ;;
    esac
  done
  return $retcode
}

function has_no_option(){
  OPTIND=1
  local retcode=0
  while getopts "$1" OPTION $SCRIPT_ARGS &>/dev/null
  do
    case $OPTION in
      $1) retcode=1
          ignore_ret_code
          break
          ;;
       ?) continue
          ;;
    esac
  done
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
  git_install lvm https://github.com/cbrinley/lvm.git
  check_point "git_install lvm https://github.com/cbrinley/lvm.git"
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


function recipes(){
  #Doc:  runs the provided chef recipes. Appropriate chef is chosen based on install.
  #Arg1: the comma seperate list of chef recipes. See chef for syntax
  #Ret:  Null
  #
  chef-solo -o $1
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
exit
}
#ACTUAL EXECUTION
main $@
