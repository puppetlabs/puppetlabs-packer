# install official epel package
# @see https://fedoraproject.org/wiki/EPEL
rpm --import https://fedoraproject.org/static/0608B895.txt
rpm -Uvh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
yum -y update