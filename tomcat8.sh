#!/bin/bash

PASS=$(pwgen -1 12 -B -n)

lvcreate -L 3G -n TOMCAT VG0
mkdir /var/lib/tomcat8
mkfs.ext4 -m0 /dev/VG0/TOMCAT
sed -i  "11i \/dev\/mapper\/VG0-TOMCAT \/var\/lib\/tomcat8            ext4     defaults\,acl 0       2" /etc/fstab
mount /var/lib/tomcat8
#add-apt-repository -y ppa:webupd8team/java
echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
#read -e -p "Enter java version (8 or 9).: " JAVA
read -e -p "Enter java version (7 or 8).: " JAVA

if [ "$JAVA" = 7 ]; then
apt-get update
apt-get install -y oracle-java7-installer oracle-java7-set-default tomcat8 tomcat8-admin tomcat8-user
TOTALMEM=$(free -m |awk '{print $2}' |head -n 2 |egrep ^'[0-9]')
XMX=$(echo "scale=0; $TOTALMEM*2/3" |bc)
NEWSIZE=$(echo "scale=0; $TOTALMEM/8" |bc)
sed -i "13i JAVA_HOME=\/usr\/lib\/jvm\/java-7-oracle" /etc/default/tomcat8
sed -i "s/^JAVA_OPTS.*/JAVA_OPTS='-server -Xms"$XMX"m -Xmx"$XMX"m -XX:NewSize="$NEWSIZE"m -XX:MaxNewSize="$NEWSIZE"m -XX:PermSize="$NEWSIZE"m -XX:MaxPermSize="$NEWSIZE"m -XX:+UseConcMarkSweepGC'/" /etc/default/tomcat8
systemctl restart tomcat8.service

#if [ "$JAVA" = 9 ]; then
#apt-get update
#apt-get install -y oracle-java9-installer oracle-java9-set-default tomcat8 tomcat8-admin tomcat8-user
#TOTALMEM=$(free -m |awk '{print $2}' |head -n 2 |egrep ^'[0-9]')
#XMX=$(echo "scale=0; $TOTALMEM*2/3" |bc)
#NEWSIZE=$(echo "scale=0; $TOTALMEM/8" |bc)
#sed -i "13i JAVA_HOME=\/usr\/lib\/jvm\/java-9-oracle" /etc/default/tomcat8
#sed -i "s/^JAVA_OPTS.*/JAVA_OPTS='-server -Xms"$XMX"m -Xmx"$XMX"m -XX:NewSize="$NEWSIZE"m -XX:MaxNewSize="$NEWSIZE"m -XX:PermSize="$NEWSIZE"m -XX:MaxPermSize="$NEWSIZE"m -XX:+UseConcMarkSweepGC'/" /etc/default/tomcat8
#systemctl restart tomcat8.service

elif [ "$JAVA" = 8 ]; then
echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
apt-get update
apt-get install -y oracle-java8-installer oracle-java8-set-default tomcat8 tomcat8-admin tomcat8-user
TOTALMEM=$(free -m |awk '{print $2}' |head -n 2 |egrep ^'[0-9]')
XMX=$(echo "scale=0; $TOTALMEM*2/3" |bc)
NEWSIZE=$(echo "scale=0; $TOTALMEM/8" |bc)
sed -i "13i JAVA_HOME=\/usr\/lib\/jvm\/java-8-oracle" /etc/default/tomcat8
sed -i "s/^JAVA_OPTS.*/JAVA_OPTS='-server -Xms"$XMX"m -Xmx"$XMX"m -XX:NewSize="$NEWSIZE"m -XX:MaxNewSize="$NEWSIZE"m -XX:PermSize="$NEWSIZE"m -XX:MaxPermSize="$NEWSIZE"m -XX:+UseConcMarkSweepGC'/" /etc/default/tomcat8
systemctl restart tomcat8.service
fi

read -e -p "Enter servers production level (prod, test or dev): " LEVEL
if [ "$LEVEL" = 'dev' ]; then
cp /root/firstrun/tomcat8/tomcat-users.xml /etc/tomcat8/tomcat-users.xml
echo -e "<user username='admin' password='$PASS' roles='manager-gui,admin-gui,manager-script,tomcat'/>" >> /etc/tomcat8/tomcat-users.xml
echo -e '\n' >> /etc/tomcat8/tomcat-users.xml
echo -e "</tomcat-users>" >> /etc/tomcat8/tomcat-users.xml
cp /root/firstrun/iptables_rules_tomcat_dev /etc/iptables_rules
iptables-restore < /etc/iptables_rules
systemctl restart tomcat8.service
elif [ "$LEVEL" = 'test' ]; then
cp /root/firstrun/tomcat8/tomcat-users.xml /etc/tomcat8/tomcat-users.xml
echo -e "<user username='admin' password='$PASS' roles='manager-gui,admin-gui,manager-script,tomcat'/>" >> /etc/tomcat8/tomcat-users.xml
echo -e "\n" >> /etc/tomcat8/tomcat-users.xml
echo -e "</tomcat-users>" >> /etc/tomcat8/tomcat-users.xml
cp /root/firstrun/tomcat8/Catalina/localhost/* /etc/tomcat8/Catalina/localhost/
systemctl restart tomcat8.service
elif [ "$LEVEL" = 'prod' ]; then
cp /root/firstrun/tomcat8/tomcat-users.xml /etc/tomcat8/tomcat-users.xml
echo -e "<user username='admin' password='$PASS' roles='manager-gui,admin-gui,manager-script,tomcat'/>" >> /etc/tomcat8/tomcat-users.xml
echo -e "\n" >> /etc/tomcat8/tomcat-users.xml
echo -e "</tomcat-users>" >> /etc/tomcat8/tomcat-users.xml
cp /root/firstrun/tomcat8/Catalina/localhost/* /etc/tomcat8/Catalina/localhost/
#cp /root/firstrun/cron.d/tomcat_iptables /etc/cron.d/
#sed -i 's/#//g' /etc/cron.d/tomcat_iptables
#cp /root/firstrun/iptables_rules_tomcat_prod /etc/iptables_rules
#iptables-restore < /etc/iptables_rules
#service cron reload
systemctl restart tomcat8.service
fi

apt-get dist-upgrade -y && apt-get autoremove --purge -y && apt-get clean

echo "Tomcat-Java installation and configuration success."
#sleep 30
#reboot
exit 0
