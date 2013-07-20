#
# Cookbook Name:: glusterfs
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute

cookbook_file "/etc/yum.repos.d/glusterfs.repo" do
  source "glusterfs.repo"
  mode 00644
end

cookbook_file "/etc/yum.repos.d/epel.repo" do
  source "epel.repo"
  mode 00644
end

yum_package "glusterfs" do
  action :install
  flush_cache [:before]
end

yum_package "glusterfs-ufo" do
  action :install
end

yum_package "glusterfs-server" do
  action :install
end

yum_package "glusterfs-geo-replication" do
  action :install
end

yum_package "glusterfs-swift-doc" do
  action :install
end

yum_package "glusterfs-fuse" do
  action :install
end

yum_package "glusterfs-swift-account" do
  action :install
end

yum_package "glusterfs-swift-container" do
  action :install
end

yum_package "glusterfs-swift-object" do
  action :install
end

yum_package "glusterfs-swift-proxy" do
  action :install
end


