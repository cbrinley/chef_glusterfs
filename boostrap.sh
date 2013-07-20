#!/bin/bash
if [ $UID -ne 0 ]; then
  echo "this script must be run as root."
  exit 1
fi


ROOT=/root
LOGFILE="$ROOT/boostrap.log"


####FUNCTIONS 
function start_block(){
  clear
  cd $ROOT
  echo $1 | awk '{ print "["strftime()"]", $0; fflush() }' | tee -a $LOGFILE
}

function log(){
  echo $1 | awk '{ print "["strftime()"]", $0; fflush() }' | tee -a $LOGFILE
}

function end_block(){
  echo '****[ SECTION COMPLETE ]****'
  echo ""
  echo ""
}

####LOGIC BLOCKS

start_block "Starting boostrap.sh"



start_block "Checking for and installing ruby if required."
rpm -Uvh http://rbel.frameos.org/rbel6 | awk '{ print "["strftime()"]", $0; fflush() }' | tee -a $LOGFILE
yum -y install ruby ruby-devel ruby-ri ruby-rdoc ruby-shadow gcc gcc-c++ automake autoconf make curl dmidecode | awk '{ print "["strftime()"]", $0; fflush() }' | tee -a $LOGFILE
end_block



start_block "Downloading and installing rubygems from source"

mkdir -p src/ruby/gems
cd src/ruby/gems
if [ ! -f rubygems-1.8.10.tgz ]; then
  curl -O http://production.cf.rubygems.org/rubygems/rubygems-1.8.10.tgz | awk '{ print "["strftime()"]", $0; fflush() }' | tee -a $LOGFILE
fi
log "Extracting source"
tar -xzf rubygems-1.8.10.tgz
cd rubygems-1.8.10
ruby setup.rb --no-format-executable | awk '{ print "["strftime()"]", $0; fflush() }' | tee -a $LOGFILE

end_block



start_block "Installing chef-solo"
gem install chef --no-ri --no-rdoc | awk '{ print "["strftime()"]", $0; fflush() }' | tee -a $LOGFILE
end_block



start_block "Installing git"
yum -y install git | awk '{ print "["strftime()"]", $0; fflush() }' | tee -a $LOGFILE
end_block



start_block "Setting up git repo for chef development."

mkdir -p src/chef
cd src/chef
if [ -d chef_glusterfs ]; then
  cd chef_glusterfs
  git pull | awk '{ print "["strftime()"]", $0; fflush() }' | tee -a $LOGFILE
else
  git clone https://github.com/cbrinley/chef_glusterfs.git | awk '{ print "["strftime()"]", $0; fflush() }' | tee -a $LOGFILE
fi

end_block



start_block "Copying chef cookbooks to system location."

cd src/chef/chef_glusterfs
mkdir -p /var/chef/cookbooks
/bin/cp -r * /var/chef/cookbooks/.

end_block



start_block "Setting up common rommand aliases"

if [ ! -f .bash_profile ]; then
  touch .bash_profile
  chmod +x .bash_profile
fi
grep alias .bash_profile | grep cp > /dev/null

end_block
