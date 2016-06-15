class windows_template::disable_sounds()
{
    # TODO Disable Windows Audio Service if it exists
    
    # Warning! Assumes Default User hive has been loaded at HKLM\DEFUSER
    registry::value { 'NoSound-DefUser-Default':
        key   => 'HKLM\DEFUSER\AppEvents\Schemes',
        value => '(default)',
        data  => '.None',
        type  => 'string'     
    }

    # TODO need more reg keys!
    $reg_list = ['AppGPFault', 'CCSelect', 'ChangeTheme']
    $reg_list.each |$regitem| {
        registry::value { "NoSound-DefUser-$regitem-Current":
            key   => "HKLM\\DEFUSER\\AppEvents\\Schemes\\.Default\\$regitem\\.Current",
            value => '(default)',
            data  => '',
            type  => 'string'     
        }
        registry::value { "NoSound-DefUser-$regitem-None":
            key   => "HKLM\\DEFUSER\\AppEvents\\Schemes\\.Default\\$regitem\\.None",
            value => '(default)',
            data  => '',
            type  => 'string'     
        }
    }
}