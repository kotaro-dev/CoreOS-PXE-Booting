#!/bin/sh

## sudo cp /usr/lib64/systemd/system/getty@.service /etc/systemd/system/autologin@.service

sudo sed -e "/^ExecStart=/c\ExecStart=-\/sbin\/agetty -a core %I 38400" /usr/lib64/systemd/system/getty@.service |sudo sed -e 's/\r$//' >/etc/systemd/system/autologin@.service

sudo mkdir /etc/systemd/system/getty.target.wants

sudo ln -s /etc/systemd/system/autologin@.service /etc/systemd/system/getty.target.wants/getty@tty1.service

sudo systemctl daemon-reload
sudo systemctl start getty@tty1.service

sudo rm /etc/systemd/system/self-login.service

sudo mv /var/lib/coreos-install/user_data /var/lib/coreos-install/user_data_bk

sudo rm /home/core/autologin.sh && sudo reboot
