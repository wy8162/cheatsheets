#!/bin/bash

# From: http://programster.blogspot.com/2013/02/centos-63-set-up-openvz.html

# BASH guard
if ! [ -n "$BASH_VERSION" ];then
    echo "this is not bash, calling self with bash....";
    SCRIPT=$(readlink -f "$0")
    /bin/bash $SCRIPT
    exit;
fi

clear
echo 'Installing OpenVZ...'

echo "updating..."
yum update -y

echo 'installing wget...'
yum install wget -y

echo "Install SSH clients"
yum install -y openssh-clients

echo "Install X11..."
yum install -y xorg-x11-xauth libXtst
yum install -y xorg-x11-fonts-base liberation-fonts
yum install -y xorg-x11-fonts-*
yum install -y xterm

echo "Adding group vz and ser ywang. User ywang will be sudoer. Make sure to change password..."
groupadd vz
adduser -m -g vz -G wheel -s /bin/bash ywang
echo "Modify /etc/sudoers to enable sudo"

echo "Enabling X11 forwarding..."
sed -i 's/#X11Forwarding yes/X11Forwarding yes/g' /etc/ssh/sshd_config
sed -i 's/#FX11DisplayOffset 10/X11DisplayOffset 10/g' /etc/ssh/sshd_config
sed -i 's/#X11UseLocalhost yes/X11UseLocalhost yes/g' /etc/ssh/sshd_config

echo 'Adding openvz Repo...'
cd /etc/yum.repos.d
wget http://download.openvz.org/openvz.repo
rpm --import http://download.openvz.org/RPM-GPG-Key-OpenVZ

echo 'Installing OpenVZ Kernel...'
yum install -y vzkernel

echo 'Installing additional tools...'
yum install vzctl vzquota ploop -y

echo 'Changing around some config files..'
sed -i 's/kernel.sysrq = 0/kernel.sysrq = 1/g' /etc/sysctl.conf

echo "Setting up packet forwarding..."
sed -i 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/g' /etc/sysctl.conf

# With vzctl 4.4 or newer there is no need to do manual configuration. Skip to #Tools_installation.
# source: http://openvz.org/Quick_installation
#echo 'net.ipv4.conf.default.proxy_arp = 0' >> /etc/sysctl.conf
#echo 'net.ipv4.conf.all.rp_filter = 1' >> /etc/sysctl.conf
#echo 'net.ipv4.conf.default.send_redirects = 1' >> /etc/sysctl.conf
#echo 'net.ipv4.conf.all.send_redirects = 0' >> /etc/sysctl.conf
#echo 'net.ipv4.icmp_echo_ignore_broadcasts=1' >> /etc/sysctl.conf
#echo 'net.ipv4.conf.default.forwarding=1' >> /etc/sysctl.conf

echo "Allowing multiple subnets to reside on the same network interface..."
sed -i 's/#NEIGHBOUR_DEVS=all/NEIGHBOUR_DEVS=all/g' /etc/vz/vz.conf
sed -i 's/NEIGHBOUR_DEVS=detect/NEIGHBOUR_DEVS=all/g' /etc/vz/vz.conf

echo "Setting container layout to default to ploop (VM in a file)..."
sed -i 's/#VE_LAYOUT=ploop/VE_LAYOUT=ploop/g' /etc/vz/vz.conf

echo "OS Template: centos-6-x86"
#echo "Setting Ubuntu 12.04 64bit to be the default template..."
#sed -i 's/centos-6-x86/ubuntu-12.04-x86_64/g' /etc/vz/vz.conf

echo 'Purging your sys configs...'
sysctl -p

echo "Disabling selinux..."
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

echo "disabling iptables..."
/etc/init.d/iptables stop && chkconfig iptables off

clear

echo "OpenVZ Is now Installed. "
echo "Please reboot into the openvz kernel to start using it."
echo "Programster"
