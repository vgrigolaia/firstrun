#!/bin/bash
# Get Access Developers To Logs And Services: Lshell Access
apt-get install acl python3 lynx curl elinks -y 
dpkg -i lshell*.deb
read -e -p "Enter  Username For DeveloperUser: " DeveloperUser
PASS=$(pwgen -1 8 -B -n)
useradd -m -d /home/$DeveloperUser -s /usr/bin/lshell -p `openssl passwd -1 $PASS` $DeveloperUser
read -e -p "Choose Tomcat Version (7 or 8). Choose Version: "  Tomcat 
if [ "$Tomcat" = 7 ]; then
setfacl -m u:$DeveloperUser:rwx /var/log/tomcat7
cp lshell.conf /etc/lshell.conf
chmod -R 755 /var/log/tomcat7
sed -i "s/develshell/$DeveloperUser/g" /etc/lshell.conf
sed -i "s/#PasswordAuthentication\ yes/PasswordAuthentication\ yes/g" /etc/ssh/sshd_config
systemctl restart sshd.service
cat << EOF >> /etc/sudoers
%$DeveloperUser   ALL = NOPASSWD: /etc/init.d/tomcat7 restart
%$DeveloperUser   ALL = NOPASSWD: /usr/sbin/service tomcat7 restart
%$DeveloperUser   ALL = NOPASSWD: /etc/init.d/tomcat7 start
%$DeveloperUser   ALL = NOPASSWD: /usr/sbin/service tomcat7 start
%$DeveloperUser   ALL = NOPASSWD: /etc/init.d/tomcat7 stop
%$DeveloperUser   ALL = NOPASSWD: /usr/sbin/service tomcat7 stop
%$DeveloperUser   ALL = NOPASSWD: /usr/bin/elinks
%$DeveloperUser   ALL = NOPASSWD: /usr/bin/curl
%$DeveloperUser   ALL = NOPASSWD: /usr/bin/lynx
EOF
elif [ "$Tomcat" = 8 ]; then
setfacl -m u:$DeveloperUser:rwx /var/log/tomcat8
cp lshell.conf /etc/lshell.conf
#sed -i "s/develshell/$DeveloperUser/g" /etc/lshell.conf
sed -i "s/tomcat7/tomcat8/g" /etc/lshell.conf
sed -i "s/%u@%h/%%u@%%h/g" /etc/lshell.conf
chmod -R 755 /var/log/tomcat8
sed -i "s/#PasswordAuthentication\ yes/PasswordAuthentication\ yes/g" /etc/ssh/sshd_config
systemctl restart sshd.service
cat << EOF >> /etc/sudoers 
%$DeveloperUser  ALL = NOPASSWD: /bin/systemctl restart tomcat8.service
%$DeveloperUser  ALL = NOPASSWD: /bin/systemctl stop tomcat8.service
%$DeveloperUser  ALL = NOPASSWD: /bin/systemctl start tomcat8.service
%$DeveloperUser  ALL = NOPASSWD: /bin/systemctl status tomcat8.service
%$DeveloperUser  ALL = NOPASSWD: /usr/bin/elinks
%$DeveloperUser  ALL = NOPASSWD: /usr/bin/curl
%$DeveloperUser  ALL = NOPASSWD: /usr/bin/lynx
EOF
fi
echo "UserName: " $DeveloperUser >> LshellUserPass.txt
echo "Password: " $PASS >> LshellUserPass.txt
echo "Lshell Access configuration success. User And Password stored in LshellUserPass.txt"
