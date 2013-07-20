#!/bin/bash
if [ $UID -ne 0 ]; then
  echo "this script must be run as root."
  exit 1
fi


ROOT=$(pwd)
LOGFILE="boostrap.log"

echo Starting boostrap.sh | awk '{ print "["strftime()"]", $0; fflush() }' >> $LOGFILE
echo "Bootstrap chef install..." | awk '{ print "["strftime()"]", $0; fflush() }' | tee -a $LOGFILE
sleep .5
clear

echo "Checking for and installing ruby if required."
rpm -Uvh http://rbel.frameos.org/rbel6 | awk '{ print "["strftime()"]", $0; fflush() }' | tee -a $LOGFILE
yum -y install ruby ruby-devel ruby-ri ruby-rdoc ruby-shadow gcc gcc-c++ automake autoconf make curl dmidecode | awk '{ print "["strftime()"]", $0; fflush() }' | tee -a $LOGFILE
clear


echo "Downloading and installing rubygems from source" | awk '{ print "["strftime()"]", $0; fflush() }' | tee -a $LOGFILE
mkdir -p src/ruby/gems
cd src/ruby/gems
if [ ! -f rubygems-1.8.10.tgz ]; then
  curl -O http://production.cf.rubygems.org/rubygems/rubygems-1.8.10.tgz | awk '{ print "["strftime()"]", $0; fflush() }' | tee -a $LOGFILE
fi
echo "Extracting source" | awk '{ print "["strftime()"]", $0; fflush() }' | tee -a $LOGFILE
tar xzf rubygems-1.8.10.tgz
cd rubygems-1.8.10
ruby setup.rb --no-format-executable | awk '{ print "["strftime()"]", $0; fflush() }' | tee -a $LOGFILE

clear
cd $ROOT

echo "Installing chef-solo" | awk '{ print "["strftime()"]", $0; fflush() }' | tee -a $LOGFILE
sudo gem install chef --no-ri --no-rdoc | awk '{ print "["strftime()"]", $0; fflush() }' | tee -a $LOGFILE

clear
echo "Installing git" | awk '{ print "["strftime()"]", $0; fflush() }' | tee -a $LOGFILE
yum -y install git | awk '{ print "["strftime()"]", $0; fflush() }' | tee -a $LOGFILE

clear
echo "Setting up git repo for chef development."
mkdir -p src/chef
cd src/chef
git clone https://github.com/cbrinley/chef_glusterfs.git

cd $ROOT
