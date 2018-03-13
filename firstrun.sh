#!/bin/bash

INIT=$(ps -p 1 |tail -n 1 |awk '{print $4}')

read -e -p "Enter servers IP address: " IP
read -e -p "Enter netmask: " NETMASK
read -e -p "Enter default gateway: " GATEWAY
read -e -p "Enter servers FQDN: " FQDN
read -e -p "In which Data-Center is this server located (Side1, Side2)?: " LOCATION
HOSTNAME=$(echo "$FQDN" | cut -d"." -f 1)

cat << EOF > /etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug eth0
#iface eth0 inet dhcp
iface eth0 inet static
address $IP
netmask $NETMASK
gateway $GATEWAY
dns-nameservers 8.8.8.8 8.8.4.4
EOF

# Set hostname in /etc/hostname

echo "$HOSTNAME" > /etc/hostname
sed -i "2i $IP	$FQDN	$HOSTNAME" /etc/hosts
# Set FQDN in /etc/mailname, /etc/postfix/main.cf
echo "$HOSTNAME" > /etc/mailname
mkdir /etc/postfix/maps
echo "root@$HOSTNAME	root@localhost"> /etc/postfix/maps/recipient_canonical
postmap /etc/postfix/maps/recipient_canonical
sed -i "s/template\.example\.gov\.ge/$FQDN/g" /etc/postfix/main.cf
echo "recipient_canonical_maps = hash:/etc/postfix/maps/recipient_canonical" >> /etc/postfix/main.cf
# Set hostname in /etc/salt/minion_id and remove /etc/init/salt-minion.override
echo "$FQDN" > /etc/salt/minion_id
rm /etc/init/salt-minion.override

if [ "$INIT" == 'systemd' ]; then
systemctl enable salt-minion.service
fi

echo "include: /etc/salt/minion.d/*" >> /etc/salt/minion

if [ "$LOCATION" == 'HQ' ]; then
cat << EOF > /etc/salt/minion.d/grains
grains:
   roles:
     - location-Side2
EOF
else
cat << EOF > /etc/salt/minion.d/grains
grains:
   roles:
     - location-Side1
EOF
fi

ifup eth0

## Uncomment and edit it if you use OMD Check_MK Monitoring System 
#wget -q --no-check-certificate -r --no-parent -A.deb https://yourdomainex.com/example/check_mk/agents/
#dpkg -Gi --force-confold yourdomainex.com/example/check_mk/agents/*.deb
#rm -rf yourdomainex.com/
#wget -q --no-check-certificate https://yourdomainex.com/example/check_mk/agents/plugins/mk_inventory.linux -O /usr/lib/check_mk_agent/plugins/mk_inventory
#chmod 755 /usr/lib/check_mk_agent/plugins/mk_inventory

apt-get update && apt-get dist-upgrade -y && apt-get autoremove --purge -y && apt-get clean

reboot
