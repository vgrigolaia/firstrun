#!/bin/bash

TOTALMEM=$(free -m |awk '{print $2}' |head -n 2 |egrep ^'[0-9]')
XMX=$(echo "scale=0; $TOTALMEM*2/3" |bc)
NEWSIZE=$(echo "scale=0; $TOTALMEM/8" |bc)
sed -i "s/^JAVA_OPTS.*/JAVA_OPTS='-server -Xms"$XMX"m -Xmx"$XMX"m -XX:NewSize="$NEWSIZE"m -XX:MaxNewSize="$NEWSIZE"m -XX:PermSize="$NEWSIZE"m -XX:MaxPermSize="$NEWSIZE"m -XX:+UseConcMarkSweepGC'/" /etc/default/tomcat*

echo -e "Tomcat startup parameters set. Now please restart tomcat manually."
