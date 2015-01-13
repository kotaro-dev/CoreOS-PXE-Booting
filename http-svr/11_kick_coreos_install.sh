#!/bin/sh

httpsvr=192.168.1.11
# branch=master
# subpath=github

# sudo wget http://${httpsvr}/cloud-config.yml -O /home/core/cloud-config.yml
# sudo wget http://${httpsvr}/12_cloud-config.yml -O /home/core/cloud-config.yml
sudo wget http://${httpsvr}/cloud-config.yml -O /home/core/cloud-config.yml

#change hostname based ip guest addr
bshstnm=gstcore
## gstip=`ip route|grep enp0s8|cut -f 12 -d " "|cut -f 4 -d .`
# gstip=`ip route|grep eth1|cut -f 12 -d " "|cut -f 4 -d .`
gstip=`ip route|grep enp0|cut -f 12 -d " "|cut -f 4 -d .`
gstnm=${bshstnm}${gstip}

echo ${gstnm}

##sed -e s/coreos-handoff/${gstnm]/g /home/core/cloud-config.yml
## sudo sed -i -e "/^hostname: /c\hostname: ${gstnm}" /home/core/cloud-config.yml
sudo sed -e "/^hostname: /c\hostname: ${gstnm}" /home/core/cloud-config.yml |sudo sed -e 's/\r$//' >/home/core/cloud-config

if [ "${bshstnm}" == "${gstnm}" ]; then
  sudo coreos-install -d /dev/sda -C stable -c /home/core/cloud-config.yml
else
  sudo coreos-install -d /dev/sda -C stable -c /home/core/cloud-config
fi

# sudo coreos-install -d /dev/sda -C stable -c /home/core/cloud-config.yml

sudo eject

sudo reboot
