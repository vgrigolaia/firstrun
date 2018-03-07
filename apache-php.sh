#!/bin/bash

HOSTNAME=$(hostname)

lvcreate -L 3G -n WWW VG0
mkdir /var/www
mkfs.ext4 -m0 /dev/VG0/WWW
sed -i  "11i \/dev\/mapper\/VG0-WWW \/var\/www            ext4     defaults\,acl 0       2" /etc/fstab
mount /var/www
apt-get update
apt-get install -y apache2 lynx
cp /root/firstrun/apache2/conf-available/security.conf /etc/apache2/conf-available/security.conf
cp /root/firstrun/apache2/envvars /etc/apache2/envvars
cp /root/firstrun/apache2/mods-available/* /etc/apache2/mods-available/
cp /root/firstrun/apache2/sites-available/000-default.conf /etc/apache2/sites-available/
a2dismod mpm_event
a2enmod mpm_prefork
sed -i  "70i ServerName $HOSTNAME" /etc/apache2/apache2.conf
systemctl restart apache2.service
read -e -p "Enter needed php version (5.6, 7.0, 7.1 or 7.2). Leave empty and press enter if no php needed: " PHP
if [ "$PHP" == 5.6 ]; then
apt-get install -y php5.6 php5.6-bz2 php5.6-cli php5.6-curl php5.6-dev php5.6-gd php5.6-intl php5.6-json php5.6-mcrypt php5.6-opcache php5.6-readline php5.6-xml php5.6-xmlrpc php5.6-xsl php5.6-zip php5.6-mbstring php5.6-bcmath libapache2-mod-php5.6
a2enmod rewrite php5.6 remoteip
cp /root/firstrun/php5/mods-available/opcache.ini /etc/php/5.6/mods-available/
cp /root/firstrun/php5/mods-available/oci8.ini /etc/php/5.6/mods-available/
cp /root/firstrun/php5/apache2/php.ini /etc/php/5.6/apache2/
echo 'autodetect' | pecl install oci8-2.0.12
phpenmod oci8
sed -i "s/template/$HOSTNAME/g" /etc/php/5.6/apache2/php.ini
cp /root/firstrun/apache2/sites-available/template.conf /etc/apache2/sites-available/"$HOSTNAME".conf
sed -i "s/template/$HOSTNAME/g" /etc/apache2/sites-available/"$HOSTNAME".conf
a2ensite "$HOSTNAME".conf
PASS=$(pwgen -1 12 -B -n)
useradd -m -d /var/www/"$HOSTNAME" -s /bin/false -p `mkpasswd -m sha-512 -s $PASS` "$HOSTNAME"
mkdir /var/www/"$HOSTNAME"/public_html
cp /root/firstrun/info.php /var/www/"$HOSTNAME"/public_html/
chown "$HOSTNAME":"$HOSTNAME" /var/www/"$HOSTNAME"/public_html -R
systemctl restart apache2.service
elif [ "$PHP" == 7.0 ]; then
apt-get install -y php7.0 php7.0-bz2 php7.0-cli php7.0-curl php7.0-dev php7.0-gd php7.0-intl php7.0-json php7.0-mcrypt php7.0-opcache php7.0-readline php7.0-xml php7.0-xmlrpc php7.0-xsl php7.0-zip php7.0-mbstring php7.0-bcmath libapache2-mod-php7.0
a2enmod rewrite php7.0 remoteip
cp /root/firstrun/php5/mods-available/opcache.ini /etc/php/7.0/mods-available/
cp /root/firstrun/php5/mods-available/oci8.ini /etc/php/7.0/mods-available/
cp /root/firstrun/php5/apache2/php.ini /etc/php/7.0/apache2/
echo 'autodetect' | pecl install oci8
phpenmod oci8
sed -i "s/template/$HOSTNAME/g" /etc/php/7.0/apache2/php.ini
cp /root/firstrun/apache2/sites-available/template.conf /etc/apache2/sites-available/"$HOSTNAME".conf
sed -i "s/template/$HOSTNAME/g" /etc/apache2/sites-available/"$HOSTNAME".conf
a2ensite "$HOSTNAME".conf
PASS=$(pwgen -1 12 -B -n)
useradd -m -d /var/www/"$HOSTNAME" -s /bin/false -p `mkpasswd -m sha-512 -s $PASS` "$HOSTNAME"
mkdir /var/www/"$HOSTNAME"/public_html
cp /root/firstrun/info.php /var/www/"$HOSTNAME"/public_html/
chown "$HOSTNAME":"$HOSTNAME" /var/www/"$HOSTNAME"/public_html -R
systemctl restart apache2.service
elif [ "$PHP" == 7.1 ]; then
apt-get install -y php7.1 php7.1-bz2 php7.1-cli php7.1-curl php7.1-dev php7.1-gd php7.1-intl php7.1-json php7.1-mcrypt php7.1-opcache php7.1-readline php7.1-xml php7.1-xmlrpc php7.1-xsl php7.1-zip php7.1-mbstring php7.1-bcmath libapache2-mod-php7.1
a2enmod rewrite php7.1 remoteip
cp /root/firstrun/php5/mods-available/opcache.ini /etc/php/7.1/mods-available/
cp /root/firstrun/php5/mods-available/oci8.ini /etc/php/7.1/mods-available/
cp /root/firstrun/php5/apache2/php.ini /etc/php/7.1/apache2/
echo 'autodetect' | pecl install oci8
phpenmod oci8
sed -i "s/template/$HOSTNAME/g" /etc/php/7.1/apache2/php.ini
cp /root/firstrun/apache2/sites-available/template.conf /etc/apache2/sites-available/"$HOSTNAME".conf
sed -i "s/template/$HOSTNAME/g" /etc/apache2/sites-available/"$HOSTNAME".conf
a2ensite "$HOSTNAME".conf
PASS=$(pwgen -1 12 -B -n)
useradd -m -d /var/www/"$HOSTNAME" -s /bin/false -p `mkpasswd -m sha-512 -s $PASS` "$HOSTNAME"
mkdir /var/www/"$HOSTNAME"/public_html
cp /root/firstrun/info.php /var/www/"$HOSTNAME"/public_html/
chown "$HOSTNAME":"$HOSTNAME" /var/www/"$HOSTNAME"/public_html -R
systemctl restart apache2.service
elif [ "$PHP" == 7.2 ]; then
apt-get install -y php7.2 php7.2-bz2 php7.2-cli php7.2-curl php7.2-dev php7.2-gd php7.2-intl php7.2-json php7.2-opcache php7.2-readline php7.2-xml php7.2-xmlrpc php7.2-xsl php7.2-zip php7.2-mbstring php7.2-bcmath libapache2-mod-php7.2
a2enmod rewrite php7.2 remoteip
cp /root/firstrun/php5/mods-available/opcache.ini /etc/php/7.2/mods-available/
cp /root/firstrun/php5/mods-available/oci8.ini /etc/php/7.2/mods-available/
cp /root/firstrun/php5/apache2/php.ini /etc/php/7.2/apache2/
echo 'autodetect' | pecl install oci8
phpenmod oci8
sed -i "s/template/$HOSTNAME/g" /etc/php/7.2/apache2/php.ini
cp /root/firstrun/apache2/sites-available/template.conf /etc/apache2/sites-available/"$HOSTNAME".conf
sed -i "s/template/$HOSTNAME/g" /etc/apache2/sites-available/"$HOSTNAME".conf
a2ensite "$HOSTNAME".conf
PASS=$(pwgen -1 12 -B -n)
useradd -m -d /var/www/"$HOSTNAME" -s /bin/false -p `mkpasswd -m sha-512 -s $PASS` "$HOSTNAME"
mkdir /var/www/"$HOSTNAME"/public_html
cp /root/firstrun/info.php /var/www/"$HOSTNAME"/public_html/
chown "$HOSTNAME":"$HOSTNAME" /var/www/"$HOSTNAME"/public_html -R
systemctl restart apache2.service
fi
read -e -p "Enter servers production level (prod, test or dev): " LEVEL
if [ "$LEVEL" == 'dev' ]; then
apt-get install -y proftpd-basic
echo "debconf shared/proftpd/inetd_or_standalone	select	from inetd" | debconf-set-selections
cp /root/firstrun/proftpd/proftpd.conf /etc/proftpd/proftpd.conf
sed -i "s/^ServerName.*/ServerName                      "$HOSTNAME"/" /etc/proftpd/proftpd.conf
cp /root/firstrun/xinetd.d/proftpd /etc/xinetd.d/proftpd
cp /root/firstrun/iptables_rules_apache /etc/iptables_rules
iptables-restore < /etc/iptables_rules
systemctl stop proftpd.service
systemctl disable proftpd.service
pkill -9 proftpd
systemctl restart xinetd.service
fi

wget -q --no-check-certificate https://youromainex.com/youromainex/check_mk/agents/plugins/apache_status -O /usr/lib/check_mk_agent/plugins/apache_status
cp /root/firstrun/apache_status.cfg /etc/check_mk/apache_status.cfg
chmod 755 /usr/lib/check_mk_agent/plugins/apache_status

apt-get dist-upgrade -y && apt-get autoremove --purge -y && apt-get clean

echo "Username: " $HOSTNAME >> /root/firstrun/user_pass.txt
echo "Password: " $PASS >> /root/firstrun/user_pass.txt

echo "Apache-PHP installation and configuration success. Username and Password for virtualhost is stored in /root/firstrun/user_pass.txt."
#sleep 30
#reboot
exit 0
