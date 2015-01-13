# CoreOS-PXE-Booting
I note the step about the CoreOS Booting via PXE(network install) for myself.  

## reference
[Booting CoreOS via PXE](https://coreos.com/docs/running-coreos/bare-metal/booting-with-pxe/)

[PXEInstallServer(Ubuntu Documentation)](https://help.ubuntu.com/community/PXEInstallServer)

[isc-dhcp-server(Ubuntu Documentation)](https://help.ubuntu.com/community/isc-dhcp-server)

## purpose
 kick the autoscale pc(physical).  
 
 WakeOnLan(Power On) -> CoreOS autoinstall -> auto login and initial setting.

## Test Environment (usng virtualbox)

```
[structure]: PXE Server in Internal network.(192.168.1.xxx)

  [vbox1]:Ubuntu14.04 server
    |     (nic1:nat) + (nic2:hostonly) + (nic3:internal)
    |     DHCP server (192.168.1.2)
    |
  [vbox2]:Ubuntu14.04 server
    |     (nic1:nat) + (nic2:hostonly) + (nic3:internal)
    |     Proxy DHCP + PXE Server (192.168.1.11) + http server(for [cloud-config-url])
    |     [dnsmasq]:installed for ProxyDHCP
    |
  [vbox3]:clern disk (for installed the CoreOS via PXE)
      [system setting : BIOS]
          starting sequence | 1.hardware 2.network
      [network setting]
          nic1:internal | adapter type[PCnet-FASTⅢ]
          nic2:nat      | adapter type[virtio-net]

```

#### [vbox1 setting]:

```
sudo apt-get install isc-dhcp-server tftpd-hpa syslinux -y

sudo vim /etc/dhcp/dhcpd.conf
[/etc/dhcp/dhcpd.conf]
ddns-update-style none;

# now comment out these 2 lines.
# option domain-name "example.org";
# option domain-name-servers ns1.example.org, ns2.example.org;

default-lease-time 600;
max-lease-time 7200;
log-facility local7;

subnet 192.168.1.0 netmask 255.255.255.0 {
    authoritative;
    range 192.168.1.101 192.168.1.199;
    option subnet-mask  255.255.255.0;
}

sudo vim /etc/network/interfaces
[/etc/network/interfaces]
auto lo
iface lo inet loopback

#nat
auto eth0
iface eth0 inet dhcp

#hsotonly network
auto eth1
iface eth1 inet static
address 192.168.56.10
netmask 255.255.255.0

#intrenal network
auto eth2
iface eth2 inet static
address 192.168.1.2
netmask 255.255.255.0

```

#### [vbox2 setting]:

```
sudo apt-get install dnsmasq syslinux -y

sudo vim /etc/dnsmasq.conf
[/etc/dnsmasq.conf]
port=0
dhcp-range=192.168.1.0,proxy
pxe-service=x86PC, "Install Linux", pxelinux
enable-tftp
tftp-root=/var/lib/tftpboot

cd /var/lib/tftpboot
sudo cp /usr/lib/syslinux/pxelinux.0 ./
sudo mkdir -p pxelinux.cfg
sudo wget http://stable.release.core-os.net/amd64-usr/current/coreos_production_pxe.vmlinuz
sudo wget http://stable.release.core-os.net/amd64-usr/current/coreos_production_pxe_image.cpio.gz

sudo vim pxelinux.cfg/default
[pxelinux.cfg/default]
default coreos
prompt 1
timeout 15

display boot.msg

label coreos
  menu default
  kernel coreos_production_pxe.vmlinuz
  append initrd=coreos_production_pxe_image.cpio.gz coreos.autologin cloud-config-url=http://192.168.1.11/kick-coreos-install.cfg

cd /var/www/html
{copy my coreos autoinstall files:[in httpsvr folder]}
```

## Operation
```
[vbox3] Power On(start)
-> show network booting message 
-> get dynamic ip from DHCP svr
-> proxy PXE server by ProxyDHCP 
-> get default file 
-> booting belongs to the default file.
-> get cloud-config from http svr.
-> start kick_coreos_install.sh
-> reboot coreos
-> autologin (changed by autologin.sh)
```

## Hints

1. [virtio-net] doesn't work for PXE Install.(we need physical network driver setting.)  
1. Don't set the BIOS sequences like this.[Network] -> [Harddisk].  
   because ... the CoreOS requested reboot for user on first install.(infinite loop)  
   So I setup 1.[Harddisk] 2.[Network] ,then if I want to re-install the CoreOS,  
   input this cmd for clearn MBR info.  
   __dd if=/dev/zero of=/dev/hdb__


## ざっくりと。

WakeOnLanと組合わせて物理PCを自動で起動させて、  
Main PC のResourceが不足した際に、  
自動的にScale outする仕組みを作成できないか試してした結果です。  
[CoreOS-hands-free](https://github.com/kotaro-dev/CoreOS-hands-free)  
と組合わせています。(internal network に合わせてIP を変更しています。)  
検証用に virtualbox で実行した際のsetting を登録しておきます。  
