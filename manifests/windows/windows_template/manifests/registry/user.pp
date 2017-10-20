# Configure the user registry settings for the default user.
# These are mainly Internet Explorer and Desktop settings.
class windows_template::registry::user ()
{
  # Set IE Home Page for this and Default User.
  registry::value { 'IE_MAIN_StartPage':
    key   => 'HKLM\\DEFUSER\\Software\\Microsoft\\Internet Explorer\\Main',
    value => 'Start Page',
    data  => 'about:blank',
    type  => 'string',
  }

  # UI and desktop settings (note classic is enforced by Group policy")
  # Set Visual Effects for Best Performance
  registry::value { 'VisualEffects_VisualFXSetting':
    key   => 'HKLM\\DEFUSER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VisualEffects',
    value => 'VisualFXSetting',
    data  => 2,
    type  => 'dword',
  }

  # Set solid color background - blueish
  registry::value { 'Colors_Background':
    key   => 'HKLM\\DEFUSER\\Control Panel\\Colors',
    value => 'Background',
    data  => '10 59 118',
    type  => 'string',
  }

  registry::value { 'Colors_Wallpaper':
    key   => 'HKLM\\DEFUSER\\Control Panel\\Colors',
    value => 'Wallpaper',
    data  => '',
    type  => 'string',
  }

  # TODO
  ##### SPECIAL
  # Win 7/8.1/10 only
  registry::value { 'Desktop_Wallpaper':
    key   => 'HKLM\\DEFUSER\\Control Panel\\Desktop',
    value => 'Wallpaper',
    data  => '',
    type  => 'string',
  }

  # Start Menu Options
  # Control panel start-menu cascading doesn't appear to be available in W 2012
  registry::value { 'ControlPanel_AllItemsIconView':
    key   => 'HKLM\\DEFUSER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\ControlPanel',
    value => 'AllItemsIconView',
    data  => 1,
    type  => 'dword',
  }

  # Icon Notification Tray - enable all notifications for the moment.
  # Setting as per spec is tricky (see RE-7692)
  registry::value { 'Explorer_':
    key   => 'HKLM\\DEFUSER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer',
    value => 'EnableAutoTray',
    data  => 0,
    type  => 'dword',
  }

  # Set Explorer UI settings
  $regvaluepairs = [ ['AlwaysShowMenus',1],
                  ['AutoCheckSelect',0],
                  ['DisablePreviewDesktop',1],
                  ['DontPrettyPath',0],
                  ['Filter',0],
                  ['Hidden',1],
                  ['HideDrivesWithNoMedia',0],
                  ['HideFileExt',0],
                  ['HideIcons',0],
                  ['HideMergeConflicts',0],
                  ['IconsOnly',1],
                  ['ListviewAlphaSelect',0],
                  ['ListviewShadow',0],
                  ['ListviewWatermark',0],
                  ['MapNetDrvBtn',0],
                  ['SeparateProcess',0],
                  ['ServerAdminUI',1],
                  ['ShowCompColor',1],
                  ['ShowInfoTip',1],
                  ['ShowStatusBar',1],
                  ['ShowSuperHidden',1],
                  ['ShowTypeOverlay',1],
                  ['Start_SearchFiles',1],
                  ['StartMenuAdminTools',1],
                  ['StartMenuInit',6],
                  ['StoreAppsOnTaskbar',1],
                  ['TaskbarAnimations',0],
                  ['TaskbarGlomLevel',1],
                  ['TaskbarSizeMove',1],
                  ['TaskbarSmallIcons',0],
                  ['WebView',1] ]

    $regvaluepairs.each | Array $regvaluepair | {
      $regvalue = $regvaluepair[0]
      $regdata = $regvaluepair[1]
      registry::value { "IE_UI_Setting_${regvalue}":
        key   => 'HKLM\\DEFUSER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced',
        value => $regvalue,
        data  => $regdata,
        type  => 'dword',
      }
    }

  # Set FullPath to be displayed in the window title bar
  registry::value { 'CabinetState_FullPath':
    key   => 'HKLM\\DEFUSER\\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState',
    value => 'FullPath',
    data  => 1,
    type  => 'dword',
  }

  # Set some UI acceleration features to tune down all of the fancy animations etc..
  registry::value { 'Desktop_DragFullWindows':
    key   => 'HKLM\\DEFUSER\\Control Panel\\Desktop',
    value => 'DragFullWindows',
    data  => '0',
    type  => 'string',
  }

  registry::value { 'Desktop_FontSmoothing':
    key   => 'HKLM\\DEFUSER\\Control Panel\\Desktop',
    value => 'FontSmoothing',
    data  => '0',
    type  => 'string',
  }

  registry::value { 'Desktop_UserPreferencesMask':
    key   => 'HKLM\\DEFUSER\\Control Panel\\Desktop',
    value => 'UserPreferencesMask',
    data  => '9000038010000000',
    type  => 'binary',
  }

  registry::value { 'WindowMetrics_MinAnimate':
    key   => 'HKLM\\DEFUSER\\Control Panel\\Desktop\WindowMetrics',
    value => 'MinAnimate',
    data  => '0',
    type  => 'string',
  }

  registry::value { 'DWM_AlwaysHibernateThumbnails':
    key   => 'HKLM\\DEFUSER\\Software\\Microsoft\\Windows\\DWM',
    value => 'AlwaysHibernateThumbnails',
    data  => 0,
    type  => 'dword',
  }

  registry::value { 'DWM_EnableAeroPeek':
    key   => 'HKLM\\DEFUSER\\Software\\Microsoft\\Windows\\DWM',
    value => 'EnableAeroPeek',
    data  => 0,
    type  => 'dword',
  }
}
