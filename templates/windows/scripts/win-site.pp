include windows_template::policies::local_group_policies
include windows_template::services::configure_services
include windows_template::registry::machine
include windows_template::registry::user
include windows_template::apps::sysinternals

# Conditional for Core checkining
# only allowed for main installs and non-core
if ($windows_install_option != 'Core') and ($::operatingsystemrelease != '2008')
{
  include windows_template::apps::chrome
}
