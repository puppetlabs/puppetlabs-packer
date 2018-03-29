# Script to run sysprep command.

# Stop the tilemode service
net stop tiledatamodelsvc

& C:\Windows\System32\sysprep\sysprep.exe /generalize /oobe /reboot /quiet /unattend:C:\Packer\Config\post-clone.autounattend.xml
