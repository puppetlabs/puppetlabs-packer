include windows_template::local_group_policies
include windows_template::configure_services


# Conditional for Core checkining
# only allowed for main installs and non-core
if ("${windows_install_option}" != 'Core') and ($::operatingsystemrelease != '2008')
{
  include windows_template::chrome
}
