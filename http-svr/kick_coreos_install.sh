#!/bin/sh

httpsvr=192.168.1.11
static_flg=0

if [ ${static_flg} -eq 0 ]; then
  #hdcp
  sudo wget http://${httpsvr}/11_kick_coreos_install.sh -O /home/core/_kick_coreos_install.sh
else
  #static ip
  sudo wget http://${httpsvr}/21_kick_coreos_install.sh -O /home/core/_kick_coreos_install.sh
fi

sudo chmod 777 /home/core/_kick_coreos_install.sh
sudo /home/core/_kick_coreos_install.sh


