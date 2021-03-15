echo Start configure Network && echo Network | tee /log_script_ht
ip a add 192.168.56.8/24 dev enp0s3
ip a | tee -a /log_script_ht
echo DONE
echo

echo Start configure SSH && echo SSH | tee -a /log_script_ht
echo Set the port for SSH
read PortSSH
sed -i "s/#Port 22/Port $PortSSH/; s/#PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config
service sshd restart | tee -a /log_script_ht
iptables -A INPUT -p tcp --dport $PortSSH -j ACCEPT
echo SSH configured. Port $PortSSH.
echo

echo Start add DVD to Repo && echo Repo | tee -a /log_script_ht
rm -Rf /etc/yum.repos.d/*                                       #Deleting all repos
touch /etc/yum.repos.d/centos7max.repo
mount /dev/cdrom /mnt | tee -a /log_script_ht
echo "[CentOS7Max]
name=CentOS 7 Max
Baseurl=file:///mnt
enabled=1
gpgkey=file:///mnt/RPM-GPG-KEY-CentOS-7" > /etc/yum.repos.d/centos7max.repo
echo DONE
echo

echo Starting to create RAID and LVM && echo SSH and LVM | tee -a /log_script_ht
echo
echo Avaliable physical discs
fdisk -l | grep "Disk /dev/sd"
echo
echo "How many discs do you need for RAID (no less than 3)"
read DiscQty
DiscPaths=()
while [ $DiscQty -gt 0 ]; do
  read -p "Enter path to disc $DiscQty: " DiscPath
  if test -e $DiscPath; then
    DiscPaths+=$DiscPath
    DiscPaths+=" "
    DiscQty=$(($DiscQty-1))
  else
    echo Wrong path
  fi
done
yum install mdadm -y | tee -a /log_script_ht
  function removeraid {                                           #clean up the RAID and LVM
    lvremove /dev/vg01
    vgremove vg01
    mdadm --stop /dev/md0
    mdadm --zero-superblock $DiscPaths}
if mdadm --detail --scan --verbose then removeraid fi           #if RAID exist - removing
mdadm --create --verbose /dev/md0 --level=5 --raid-devices=3 $DiscPaths | tee -a /log_script_ht

mkdir /etc/mdadm                                                #creating of file with setap of created RAID
echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf

echo RAID DONE
pvcreate /dev/md0 | tee -a /log_script_ht
vgcreate vg01 /dev/md0 | tee -a /log_script_ht
lvcreate -l 100%FREE vg01 | tee -a /log_script_ht
mkfs.xfs /dev/vg01/vol0 | tee -a /log_script_ht
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

echo Setting NFS folder && echo NFS | tee -a /log_script_ht
yum install nfs-utils | tee -a /log_script_ht
systemctl start rpcbind | tee -a /log_script_ht
systemctl enable rpcbind | tee -a /log_script_ht
systemctl start nfs-server | tee -a /log_script_ht
systemctl enable nfs-server | tee -a /log_script_ht
systemctl start rpc-stand | tee -a /log_script_ht
systemctl start nfs-idmapd | tee -a /log_script_ht
mkdir /NetFolder | tee -a /log_script_ht
chmod 777 /NetFolder | tee -a /log_script_ht
echo "/NetFolder *(rw,sync,no_root_squach)" | tee -a /etc/exports
echo /NetFolder set as NFS folder
