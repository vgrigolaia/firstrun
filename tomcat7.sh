#!/bin/bash

PASS=$(pwgen -1 12 -B -n)

lvcreate -L 3G -n TOMCAT VG0
mkdir /var/lib/tomcat7
mkfs.ext4 -m0 /dev/VG0/TOMCAT
sed -i  "11i \/dev\/mapper\/VG0-TOMCAT \/var\/lib\/tomcat7            ext4     defaults\,acl 0       2" /etc/fstab
mount /var/lib/tomcat7
#add-apt-repository -y ppa:webupd8team/java
echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
read -e -p "Enter java version (7 or 8).: " JAVA
if [ "$JAVA" = 7 ]; then
apt-get update
apt-get install -y oracle-java7-installer oracle-java7-set-default tomcat7 tomcat7-admin tomcat7-user
TOTALMEM=$(free -m |awk '{print $2}' |head -n 2 |egrep ^'[0-9]')
XMX=$(echo "scale=0; $TOTALMEM*2/3" |bc)
NEWSIZE=$(echo "scale=0; $TOTALMEM/8" |bc)
sed -i "13i JAVA_HOME=\/usr\/lib\/jvm\/java-8-oracle" /etc/default/tomcat7
sed -i "s/^JAVA_OPTS.*/JAVA_OPTS='-server -Xms"$XMX"m -Xmx"$XMX"m -XX:NewSize="$NEWSIZE"m -XX:MaxNewSize="$NEWSIZE"m -XX:PermSize="$NEWSIZE"m -XX:MaxPermSize="$NEWSIZE"m -XX:+UseConcMarkSweepGC'/" /etc/default/tomcat7
service tomcat7 start
elif [ "$JAVA" = 8 ]; then
echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
apt-get update
apt-get install -y oracle-java8-installer oracle-java8-set-default tomcat7 tomcat7-admin tomcat7-user
TOTALMEM=$(free -m |awk '{print $2}' |head -n 2 |egrep ^'[0-9]')
XMX=$(echo "scale=0; $TOTALMEM*2/3" |bc)
NEWSIZE=$(echo "scale=0; $TOTALMEM/8" |bc)
sed -i "13i JAVA_HOME=\/usr\/lib\/jvm\/java-8-oracle" /etc/default/tomcat7
sed -i "s/^JAVA_OPTS.*/JAVA_OPTS='-server -Xms"$XMX"m -Xmx"$XMX"m -XX:NewSize="$NEWSIZE"m -XX:MaxNewSize="$NEWSIZE"m -XX:PermSize="$NEWSIZE"m -XX:MaxPermSize="$NEWSIZE"m -XX:+UseConcMarkSweepGC'/" /etc/default/tomcat7
fi

read -e -p "Enter servers production level (prod, test or dev): " LEVEL
if [ "$LEVEL" = 'dev' ]; then
cp /root/firstrun/tomcat7/tomcat-users.xml /etc/tomcat7/tomcat-users.xml
echo -e "<user username='admin' password='$PASS' roles='manager-gui,admin-gui,manager-script,tomcat'/>" >> /etc/tomcat7/tomcat-users.xml
echo -e '\n' >> /etc/tomcat7/tomcat-users.xml
echo -e "</tomcat-users>" >> /etc/tomcat7/tomcat-users.xml
cp /root/firstrun/iptables_rules_tomcat_dev /etc/iptables_rules
iptables-restore < /etc/iptables_rules
service tomcat7 restart
elif [ "$LEVEL" = 'test' ]; then
cp /root/firstrun/tomcat7/tomcat-users.xml /etc/tomcat7/tomcat-users.xml
echo -e "<user username='admin' password='$PASS' roles='manager-gui,admin-gui,manager-script,tomcat'/>" >> /etc/tomcat7/tomcat-users.xml
echo -e "\n" >> /etc/tomcat7/tomcat-users.xml
echo -e "</tomcat-users>" >> /etc/tomcat7/tomcat-users.xml
cp /root/firstrun/tomcat7/Catalina/localhost/* /etc/tomcat7/Catalina/localhost/
service tomcat7 restart
elif [ "$LEVEL" = 'prod' ]; then
cp /root/firstrun/tomcat7/tomcat-users.xml /etc/tomcat7/tomcat-users.xml
echo -e "<user username='admin' password='$PASS' roles='manager-gui,admin-gui,manager-script,tomcat'/>" >> /etc/tomcat7/tomcat-users.xml
echo -e "\n" >> /etc/tomcat7/tomcat-users.xml
echo -e "</tomcat-users>" >> /etc/tomcat7/tomcat-users.xml
cp /root/firstrun/tomcat7/Catalina/localhost/* /etc/tomcat7/Catalina/localhost/
cp /root/firstrun/cron.d/tomcat_iptables /etc/cron.d/
#sed -i 's/#//g' /etc/cron.d/tomcat_iptables
#service cron reload
cp /root/firstrun/iptables_rules_tomcat_prod /etc/iptables_rules
#iptables-restore < /etc/iptables_rules
service tomcat7 restart
fi

apt-get dist-upgrade -y && apt-get autoremove --purge -y && apt-get clean

echo "Tomcat-Java installation and configuration success."
#sleep 30
#reboot
exit 0
