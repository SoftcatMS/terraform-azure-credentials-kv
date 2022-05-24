#!/bin/sh

# Provision data disks
if [ -d "/dev/disk/azure/scsi1/" ]; then
    cd /dev/disk/azure/scsi1/;

    for LUN in *
    do 
      NUM=$(echo "$LUN" | grep -o -E "[0-9]+")
      if [ -d "/mnt/data$NUM" ]; then
          echo "Disk Exists";
      else
          echo "y" | mkfs.ext4 /dev/disk/azure/scsi1/"$LUN";
          mkdir /mnt/data"$NUM";
          echo "/dev/disk/azure/scsi1/$LUN /mnt/data$NUM ext4 defaults,nofail 0 0" >>/etc/fstab;
      fi
    done

    mount -a
else
    echo " Path /dev/disk/azure/scsi1/ does not exist";
fi



# Add Softcatadmin user
if id -u "softcatadmin" >/dev/null 2>&1; then
    echo "softcatadmin exists";
else
    useradd -md /home/softcatadmin softcatadmin;
    usermod -aG sudo softcatadmin;
    echo softcatadmin:'C0mpl3xP4sswd' | chpasswd;
fi
