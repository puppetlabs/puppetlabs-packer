# Clear wtmp
cat /dev/null > /var/adm/wtmpx

# Zero out the free space to save space in the final image:
dd if=/dev/zero of=/EMPTY bs=1024
rm -f /EMPTY

# Remove this script
rm -rf /tmp/script.sh

# Wait for all file ops to complete
sync
