echo Start configure Network
ip a add 192.168.56.8/24 dev enp0s3
ip a
echo DONE
echo

echo Start configure SSH
echo Set the port for SSH
read PortSSH
sed -i "s/#Port 22/Port $PortSSH/; s/#PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config
service sshd restart
iptables -A INPUT -p tcp --dport $PortSSH -j ACCEPT
echo SSH configured. Port $PortSSH.
echo

echo Start add DVD to Repo
rm -Rf /etc/yum.repos.d/*                                #Deleting all repos
touch /etc/yum.repos.d/centos7max.repo
mount /dev/cdrom /mnt
echo "[CentOS7Max]
name=CentOS 7 Max
Baseurl=file:///mnt
enabled=1
gpgkey=file:///mnt/RPM-GPG-KEY-CentOS-7" > /etc/yum.repos.d/centos7max.repo
echo DONE
echo

echo Starting to create RAID and LVM
echo
echo Avaliable physical discs
fdisk -l | grep "Disk /dev/sd"
echo
echo "How many discs do you need for RAID (no less than 3)"
read DiscQty
DiscPaths=()
while [ $DiscQty -gt 0 ]; do
  read -p "Enter way to disc $DiscQty: " DiscPath
  if test -e $DiscPath; then
    DiscPaths+=$DiscPath
    DiscPaths+=" "
    DiscQty=$(($DiscQty-1))
  else
    echo Wrong way
  fi
done
yum install mdadm -y
  lvremove /dev/vg01                                   #clean up in case script was running before
  vgremove vg01
  mdadm --stop /dev/md0
  mdadm --zero-superblock $DiscPaths
mdadm --create --verbose /dev/md0 --level=5 --raid-devices=3 $DiscPaths
echo RAID DONE
pvcreate /dev/md0
vgcreate vg01 /dev/md0
lvcreate -l 100%FREE vg01
mkfs.xfs /dev/vg01/vol0
echo LVM DONE
echo

echo Mounting volume
echo Set mounting point
while [ 1 ]; do
  read MountPoint
  if test -e $MountPoint; then
    mount /dev/vg10/lvol0 $MountPoint
    break
  else
    echo "Mounting point doesn't exist. It will be ctreate"
    mkdir -p $MountPoint
  fi
done

echo Setting NFS folder
yum install nfs-utils
systemctl start rpcbind
systemctl enable rpcbind
systemctl start nfs-server
systemctl enable nfs-server
systemctl start rpc-stand
systemctl start nfs-idmapd
mkdir /NetFolder
chmod 777 /NetFolder
echo "/NetFolder *(rw,sync,no_root_squach)" | tee -a /etc/exports
echo /NetFolder set as NFS folder
