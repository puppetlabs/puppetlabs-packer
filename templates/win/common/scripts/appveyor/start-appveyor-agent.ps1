# Modified run agent for Puppet/GCE Environments.
# Check if we are appveyor user, otherwise exit.
#
if ("$Env:Username" -eq "appveyor") {
    # run agent
    & "$env:ProgramFiles\AppVeyor\BuildAgent\Appveyor.BuildAgent.Interactive.exe"
}
