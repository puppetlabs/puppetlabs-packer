#!/bin/bash
#
# Script to provision Red Hat repos 
redhat_repos="/etc/yum.repos.d/redhat.repo"

repo_template=$'[rhel7-template]
name=Red Hat Enterprise Linux 7 - $basearch OptRepoName
baseurl=http://osmirror.delivery.puppetlabs.net/rhel7latestserver-x86_64/RPMS.template/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release

'

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
