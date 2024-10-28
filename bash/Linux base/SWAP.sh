# Creating
swapon --show                                       # Empty output means swap isn't configured
dd if=/dev/zero of=/swapfile bs=1024 count=1048576  # count=1048576=(1024x1024)
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile swap swap defaults 0 0' >> /etc/fstab
swapon --show

# Deleting
swapoff -v /swapfile

# Delete '/swapfile swap swap defaults 0 0' in /etc/fstab
rm -f /swapfile

# Show SWAP
for file in /proc/*/status ; \
    do awk '/VmSwap|Name/{printf $2 " " $3}END{ print ""}' $file; \
done | sort -k 2 -n -r | head -n 15