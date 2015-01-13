#!/bin/sh

httpsvr=192.168.1.11
# branch=master
# subpath=github

## add network setting block to based cloud-conifg.yml
sudo wget http://${httpsvr}/12_cloud-config.yml -O /home/core/12_cloud-config.yml
sudo wget http://${httpsvr}/22_cloud-config-staticip.yml -O /home/core/22_cloud-config-staticip.yml

sudo cat /home/core/12_cloud-config.yml /home/core/22_cloud-config-staticip.yml > /home/core/cloud-config.yml

## setting static ip
staticip=192.168.1.90

#change hostname based ip from static ip
bshstnm=gstcore
gstip=`echo ${staticip}|cut -f 4 -d .`

gstnm=${bshstnm}${gstip}

echo ${gstnm}

##sed -e s/coreos-handoff/${gstnm]/g /home/core/cloud-config.yml
## sudo sed -i -e "/^hostname: /c\hostname: ${gstnm}" /home/core/cloud-config.yml
sudo sed -e "/^hostname: /c\hostname: ${gstnm}" /home/core/cloud-config.yml |sudo sed -e 's/\r$//' >/home/core/cloud-config.0

## sed Address to staticip
sudo sed -e "/^\s\+Address=/c\      Address=${staticip}\/24" /home/core/cloud-config.0 |sudo sed -e 's/\r$//' >/home/core/cloud-config.1

## sed hostname at hosts file
sudo sed -e "/^\s\+127.0.1.1 /c\      127.0.1.1 ${gstnm}" /home/core/cloud-config.1 |sudo sed -e 's/\r$//' >/home/core/cloud-config


if [ "${bshstnm}" == "${gstnm}" ]; then
  sudo coreos-install -d /dev/sda -C stable -c /home/core/cloud-config.yml
else
  sudo coreos-install -d /dev/sda -C stable -c /home/core/cloud-config
fi

sudo eject

sudo reboot

