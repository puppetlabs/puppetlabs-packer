define windows_group_policy::local::machine_client_side_extensions(
  $ensure    = 'present',

  $ieee802_3_group_policy = false,
  $application_management = false,
  $audit_policy_configuration = false,
  $certificates_run_restriction = false,
  $computer_restricted_groups = false,
  $data_sources_preference = false,
  $deployed_printer_connections = false,
  $devices_preference = false,
  $drives_preference = false,
  $efs_recovery = false,
  $enterprise_qos = false,
  $environment_variables_preference = false,
  $files_preference = false,
  $folder_options_preference = false,
  $folder_redirection = false,
  $folders_preference = false,
  $group_policy_applications = false,
  $group_policy_folders = false,
  $ini_files_preference = false,
  $internet_explorer_machine_accelerators = false,
  $internet_explorer_maintenance_extension_protocol = false,
  $internet_explorer_maintenance_policy_processing = false,
  $internet_explorer_zonemapping = false,
  $internet_settings_preference = false,
  $ip_security = false,
  $local_users_and_groups_preference = false,
  $logon_logoff_scripts_run_restriction = false,
  $microsoft_disk_quota = false,
  $microsoft_offline_files = false,
  $network_options_preference = false,
  $network_shares_preference = false,
  $power_options_preference = false,
  $printers_preference = false,
  $process_scripts_grouppolicy = false,
  $regional_options_preference = false,
  $registry_preference = false,
  $registry_settings = true,
  $remote_installation_services = false,
  $scheduled_tasks_preference = false,
  $security = false,
  $services_preference = false,
  $shortcuts_preference = false,
  $software_installation = false,
  $start_menu_preference = false,
  $tcpip = false,

  # Add Ability to add arbitrary GUIDs
  $guidlist = '',

  $logoutput = false,
)
{
  # Add default GPEEDIT Tool Extensions GUIDs
  $defaultextensionlist = "{D02B1F73-3407-48AE-BA88-E8213C6761F1}{0F6B957E-509E-11D1-A7CC-0000F87571E3}"  

  if ($ieee802_3_group_policy) { $ieee802_3_group_policy_guid = "{B587E2B1-4D59-4E7E-AED9-22B9DF11D053}" } else { $ieee802_3_group_policy_guid = ""}
  if ($application_management) { $application_management_guid = "{C6DC5466-785A-11D2-84D0-00C04FB169F7}" } else { $application_management_guid = ""}
  if ($audit_policy_configuration) { $audit_policy_configuration_guid = "{F3CCC681-B74C-4060-9F26-CD84525DCA2A}" } else { $audit_policy_configuration_guid = ""}
  if ($certificates_run_restriction) { $certificates_run_restriction_guid = "{53D6AB1D-2488-11D1-A28C-00C04FB94F17}" } else { $certificates_run_restriction_guid = ""}
  if ($computer_restricted_groups) { $computer_restricted_groups_guid = "{803E14A0-B4FB-11D0-A0D0-00A0C90F574B}" } else { $computer_restricted_groups_guid = ""}
  if ($data_sources_preference) { $data_sources_preference_guid = "{728EE579-943C-4519-9EF7-AB56765798ED}{1612B55C-243C-48DD-A449-FFC097B19776}" } else { $data_sources_preference_guid = ""}
  if ($deployed_printer_connections) { $deployed_printer_connections_guid = "{8A28E2C5-8D06-49A4-A08C-632DAA493E17}" } else { $deployed_printer_connections_guid = ""}
  if ($devices_preference) { $devices_preference_guid = "{1A6364EB-776B-4120-ADE1-B63A406A76B5}{1B767E9A-7BE4-4D35-85C1-2E174A7BA951}" } else { $devices_preference_guid = ""}
  if ($drives_preference) { $drives_preference_guid = "{5794DAFD-BE60-433F-88A2-1A31939AC01F}{2EA1A81B-48E5-45E9-8BB7-A6E3AC170006}" } else { $drives_preference_guid = ""}
  if ($efs_recovery) { $efs_recovery_guid = "{B1BE8D72-6EAC-11D2-A4EA-00C04F79F83A}" } else { $efs_recovery_guid = ""}
  if ($enterprise_qos) { $enterprise_qos_guid = "{FB2CA36D-0B40-4307-821B-A13B252DE56C}" } else { $enterprise_qos_guid = ""}
  if ($environment_variables_preference) { $environment_variables_preference_guid = "{35141B6B-498A-4CC7-AD59-CEF93D89B2CE}{0E28E245-9368-4853-AD84-6DA3BA35BB75}" } else { $environment_variables_preference_guid = ""}
  if ($files_preference) { $files_preference_guid = "{7150F9BF-48AD-4DA4-A49C-29EF4A8369BA}{3BAE7E51-E3F4-41D0-853D-9BB9FD47605F}" } else { $files_preference_guid = ""}
  if ($folder_options_preference) { $folder_options_preference_guid = "{A3F3E39B-5D83-4940-B954-28315B82F0A8}{3BFAE46A-7F3A-467B-8CEA-6AA34DC71F53}" } else { $folder_options_preference_guid = ""}
  if ($folder_redirection) { $folder_redirection_guid = "{25537BA6-77A8-11D2-9B6C-0000F8080861}{88E729D6-BDC1-11D1-BD2A-00C04FB9603F}" } else { $folder_redirection_guid = ""}
  if ($folders_preference) { $folders_preference_guid = "{6232C319-91AC-4931-9385-E70C2B099F0E}{3EC4E9D3-714D-471F-88DC-4DD4471AAB47}" } else { $folders_preference_guid = ""}
  if ($group_policy_applications) { $group_policy_applications_guid = "{F9C77450-3A41-477E-9310-9ACD617BD9E3}" } else { $group_policy_applications_guid = ""}
  if ($group_policy_folders) { $group_policy_folders_guid = "{6232C319-91AC-4931-9385-E70C2B099F0E}" } else { $group_policy_folders_guid = ""}
  if ($ini_files_preference) { $ini_files_preference_guid = "{74EE6C03-5363-4554-B161-627540339CAB}{516FC620-5D34-4B08-8165-6A06B623EDEB}" } else { $ini_files_preference_guid = ""}
  if ($internet_explorer_machine_accelerators) { $internet_explorer_machine_accelerators_guid = "{CF7639F3-ABA2-41DB-97F2-81E2C5DBFC5D}" } else { $internet_explorer_machine_accelerators_guid = ""}
  if ($internet_explorer_maintenance_extension_protocol) { $internet_explorer_maintenance_extension_protocol_guid = "{FC715823-C5FB-11D1-9EEF-00A0C90347FF}" } else { $internet_explorer_maintenance_extension_protocol_guid = ""}
  if ($internet_explorer_maintenance_policy_processing) { $internet_explorer_maintenance_policy_processing_guid = "{A2E30F80-D7DE-11D2-BBDE-00C04F86AE3B}" } else { $internet_explorer_maintenance_policy_processing_guid = ""}
  if ($internet_explorer_zonemapping) { $internet_explorer_zonemapping_guid = "{4CFB60C1-FAA6-47F1-89AA-0B18730C9FD3}" } else { $internet_explorer_zonemapping_guid = ""}
  if ($internet_settings_preference) { $internet_settings_preference_guid = "{E47248BA-94CC-49C4-BBB5-9EB7F05183D0}{5C935941-A954-4F7C-B507-885941ECE5C4}" } else { $internet_settings_preference_guid = ""}
  if ($ip_security) { $ip_security_guid = "{E437BC1C-AA7D-11D2-A382-00C04F991E27}" } else { $ip_security_guid = ""}
  if ($local_users_and_groups_preference) { $local_users_and_groups_preference_guid = "{17D89FEC-5C44-4972-B12D-241CAEF74509}{79F92669-4224-476C-9C5C-6EFB4D87DF4A}" } else { $local_users_and_groups_preference_guid = ""}
  if ($logon_logoff_scripts_run_restriction) { $logon_logoff_scripts_run_restriction_guid = "{40B66650-4972-11D1-A7CA-0000F87571E3}" } else { $logon_logoff_scripts_run_restriction_guid = ""}
  if ($microsoft_disk_quota) { $microsoft_disk_quota_guid = "{3610EDA5-77EF-11D2-8DC5-00C04FA31A66}" } else { $microsoft_disk_quota_guid = ""}
  if ($microsoft_offline_files) { $microsoft_offline_files_guid = "{C631DF4C-088F-4156-B058-4375F0853CD8}" } else { $microsoft_offline_files_guid = ""}
  if ($network_options_preference) { $network_options_preference_guid = "{3A0DBA37-F8B2-4356-83DE-3E90BD5C261F}{949FB894-E883-42C6-88C1-29169720E8CA}" } else { $network_options_preference_guid = ""}
  if ($network_shares_preference) { $network_shares_preference_guid = "{6A4C88C6-C502-4F74-8F60-2CB23EDC24E2}{BFCBBEB0-9DF4-4C0C-A728-434EA66A0373}" } else { $network_shares_preference_guid = ""}
  if ($power_options_preference) { $power_options_preference_guid = "{E62688F0-25FD-4C90-BFF5-F508B9D2E31F}{9AD2BAFE-63B4-4883-A08C-C3C6196BCAFD}" } else { $power_options_preference_guid = ""}
  if ($printers_preference) { $printers_preference_guid = "{BC75B1ED-5833-4858-9BB8-CBF0B166DF9D}{A8C42CEA-CDB8-4388-97F4-5831F933DA84}" } else { $printers_preference_guid = ""}
  if ($process_scripts_grouppolicy) { $process_scripts_grouppolicy_guid = "{42B5FAAE-6536-11D2-AE5A-0000F87571E3}" } else { $process_scripts_grouppolicy_guid = ""}
  if ($regional_options_preference) { $regional_options_preference_guid = "{E5094040-C46C-4115-B030-04FB2E545B00}{B9CCA4DE-E2B9-4CBD-BF7D-11B6EBFBDDF7}" } else { $regional_options_preference_guid = ""}
  if ($registry_preference) { $registry_preference_guid = "{B087BE9D-ED37-454F-AF9C-04291E351182}{BEE07A6A-EC9F-4659-B8C9-0B1937907C83}" } else { $registry_preference_guid = ""}
  if ($registry_settings) { $registry_settings_guid = "{35378EAC-683F-11D2-A89A-00C04FBBCFA2}" } else { $registry_settings_guid = ""}
  if ($remote_installation_services) { $remote_installation_services_guid = "{3060E8CE-7020-11D2-842D-00C04FA372D4}" } else { $remote_installation_services_guid = ""}
  if ($scheduled_tasks_preference) { $scheduled_tasks_preference_guid = "{AADCED64-746C-4633-A97C-D61349046527}{CAB54552-DEEA-4691-817E-ED4A4D1AFC72}" } else { $scheduled_tasks_preference_guid = ""}
  if ($security) { $security_guid = "{827D319E-6EAC-11D2-A4EA-00C04F79F83A}" } else { $security_guid = ""}
  if ($services_preference) { $services_preference_guid = "{91FBB303-0CD5-4055-BF42-E512A681B325}{CC5746A9-9B74-4BE5-AE2E-64379C86E0E4}" } else { $services_preference_guid = ""}
  if ($shortcuts_preference) { $shortcuts_preference_guid = "{C418DD9D-0D14-4EFB-8FBF-CFE535C8FAC7}{CEFFA6E2-E3BD-421B-852C-6F6A79A59BC1}" } else { $shortcuts_preference_guid = ""}
  if ($software_installation) { $software_installation_guid = "{942A8E4F-A261-11D1-A760-00C04FB9603F}" } else { $software_installation_guid = ""}
  if ($start_menu_preference) { $start_menu_preference_guid = "{E4F48E54-F38D-4884-BFB9-D4D2E5729C18}{CF848D48-888D-4F45-B530-6A201E62A605}" } else { $start_menu_preference_guid = ""}
  if ($tcpip) { $tcpip_guid = "{CDEAFC3D-948D-49DD-AB12-E578BA4AF7AA}" } else { $tcpip_guid = ""}

  $policy_extensionlist = "${defaultextensionlist}${ieee802_3_group_policy_guid}${application_management_guid}${audit_policy_configuration_guid}${certificates_run_restriction_guid}${computer_restricted_groups_guid}${data_sources_preference_guid}${deployed_printer_connections_guid}${devices_preference_guid}${drives_preference_guid}${efs_recovery_guid}${enterprise_qos_guid}${environment_variables_preference_guid}${files_preference_guid}${folder_options_preference_guid}${folder_redirection_guid}${folders_preference_guid}${group_policy_applications_guid}${group_policy_folders_guid}${ini_files_preference_guid}${internet_explorer_machine_accelerators_guid}${internet_explorer_maintenance_extension_protocol_guid}${internet_explorer_maintenance_policy_processing_guid}${internet_explorer_zonemapping_guid}${internet_settings_preference_guid}${ip_security_guid}${local_users_and_groups_preference_guid}${logon_logoff_scripts_run_restriction_guid}${microsoft_disk_quota_guid}${microsoft_offline_files_guid}${network_options_preference_guid}${network_shares_preference_guid}${power_options_preference_guid}${printers_preference_guid}${process_scripts_grouppolicy_guid}${regional_options_preference_guid}${registry_preference_guid}${registry_settings_guid}${remote_installation_services_guid}${scheduled_tasks_preference_guid}${security_guid}${services_preference_guid}${shortcuts_preference_guid}${software_installation_guid}${start_menu_preference_guid}${tcpip_guid}${guidlist}"

  $policy_type = 'Machine'

  if $ensure in ['present'] {
    exec { "GPO-Local-UserCSE-$name":
      command => template('windows_group_policy/script_header.ps1',
                          'windows_group_policy/gp_extensions.ps1',
                          'windows_group_policy/local_gpo_ext.ps1',
                          'windows_group_policy/ext_command-set.ps1'),
      unless => template('windows_group_policy/script_header.ps1',
                         'windows_group_policy/gp_extensions.ps1',
                         'windows_group_policy/local_gpo_ext.ps1',
                         'windows_group_policy/ext_command-unless.ps1'),
      provider => powershell,
      logoutput => $logoutput,
    }
  } else {
    # Do stuff to remove it
    Notify{ '***** Removing GPOs is NOT IMPLEMENTED': }
  }
}
