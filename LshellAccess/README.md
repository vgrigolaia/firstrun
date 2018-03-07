Get Access Developers To Logs And Services: Lshell Access
Developers Service Commands
Log Path: /var/log/tomcat[7-8]
## Tomcat 7
 /etc/init.d/tomcat7 restart
 /usr/sbin/service tomcat7 restart
 /etc/init.d/tomcat7 start
 /usr/sbin/service tomcat7 start
 /etc/init.d/tomcat7 stop
 /usr/sbin/service tomcat7 stop
 /usr/bin/elinks
 /usr/bin/curl
 /usr/bin/lynx
 sudo service tomcat7 restart
 
## Tomcat 8
/bin/systemctl restart tomcat8.service
/bin/systemctl stop tomcat8.service
/bin/systemctl start tomcat8.service
/bin/systemctl status tomcat8.service
/usr/bin/elinks
/usr/bin/curl
/usr/bin/lynx
sudo systemctl restart tomcat8.service
