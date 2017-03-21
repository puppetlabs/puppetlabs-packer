yum -y update
yum -y install wget curl openssh-server

# Install root certificates
yum -y install ca-certificates

# Make ssh faster by not waiting on DNS
echo "UseDNS no" >> /etc/ssh/sshd_config

#Build the ens32 interface for RHEL 7.0
cat << EOF > /etc/sysconfig/network-scripts/ifcfg-ens32
ONBOOT=yes
BOOTPROTO=dhcp
DEVICE=ens32
EOF
