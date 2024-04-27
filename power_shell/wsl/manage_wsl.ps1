# wsl --version
# wsl --list
# wsl --update

# wsl --import Ubuntu-22.04 D:\wsl\ D:\Ubuntu.tar
# wsl --unregister Ubuntu-22.04
# wsl --import Ubuntu-22.04 d:\wsl\Ubuntu-22.04 D:\Ubuntu.tar

# wsl --list --online

# Optimized wsl disk size
wsl --shutdown
wsl --list --running
$VHDX_PATH = "C:\Users\$username\AppData\Local\Packages\CanonicalGroupLimited.Ubuntu22.04LTS_79rhkp1fndgsc\LocalState\"
optimize-vhd -Path $VHDX_PATH\ext4.vhdx -Mode full

# Create wsl backup
$WSL_BACKUP_PATH = "D:\Ubuntu.tar"
wsl --export 'Ubuntu-22.04 (Default)' $WSL_BACKUP_PATH

#Restore wsl from backup
$WSL_BACKUP_PATH = "D:\Ubuntu.tar"
$LINUX_OS_VERS = "Ubuntu-22.04"
$WSL_PATH = "D:\wsl\$LINUX_OS_VERS"

mkdir D:\wsl\$LINUX_OS_VERS
wsl --set-version $LINUX_OS_VERS 2
wsl --install $LINUX_OS_VERS
wsl --unregister $LINUX_OS_VERS
wsl --import $LINUX_OS_VERS $WSL_PATH $WSL_BACKUP_PATH
ubuntu2204.exe config --default-user $username
wsl --set-default $LINUX_OS_VERS
