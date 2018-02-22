#!/bin/bash
#
# After installation, RHEL doesn't have any yum repos configured. This
# script provisions our local RHEL mirror repos.
redhat_repos="/etc/yum.repos.d/osmirror.repo"

# OS Version and arch detection
# This parses the major release version from e.g: "Red Hat Enterprise Linux Server release 6.5 (Santiago)"
os_ver=`cat /etc/redhat-release | sed 's/.*release \([[:digit:]]\).*/\1/'`
os_arch=`uname -m`
if [ "$os_arch" == "i686" ]; then
  os_arch="i386"
fi

repo_template=$"[rhel$os_ver-template]
name=Red Hat Enterprise Linux $os_ver - \$basearch OptRepoName
baseurl=http://osmirror.delivery.puppetlabs.net/rhel${os_ver}latestserver-$os_arch/RPMS.template/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release

"

repos=("os" "updates" "optional" "extras")
repo_names=("" "" "- Optional" "- Extras")

num_repos=${#repos[@]}

# Generate the repo's from the template while adjusting their urls, names and enable state
for (( i=1; i<${num_repos}+1; i++ ));
do
    repo_str=`echo "$repo_template" | sed "s/template/${repos[$i-1]}/g"` 
    named_repo_str=`echo "$repo_str" | sed "s/OptRepoName/${repo_names[$i-1]}/g"` 
    if [ "${repos[$i-1]}" == "extras" ]; then
        final_repo_str=`echo "$named_repo_str" | sed "s/enabled=1/enabled=0/g"` 
    else
        final_repo_str=$named_repo_str 
    fi

    echo "$final_repo_str" >> $redhat_repos
    echo "" >> $redhat_repos
done
