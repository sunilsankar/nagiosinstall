#!/bin/bash
#Author Sunil Sankar
#Date 4 Sep 2012
#Purpose : Installation of Nagios and also intergrate merlin and ninja
DOWNLOAD_DIR=/root/packages
NAGIOSPATH=/opt/nagios
FILE=./root/Nagios.txt.
WGET=`/usr/bin/wget`
NAGIOSDOWNLOAD=http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-3.4.1.tar.gz
NAGIOSPLUGIN=http://prdownloads.sourceforge.net/sourceforge/nagiosplug/nagios-plugins-1.4.16.tar.gz
MERLIN=git://git.op5.org/nagios/merlin.git
NINJA=git://git.op5.org/nagios/ninja.git
download () {
mkdir -p $DOWNLOAD_DIR
cd $DOWNLOAD_DIR
echo "Downloading Nagios Core 3.4.1"
wget $NAGIOSDOWNLOAD
echo "Downloading Nagios Plugins 1.4.16"
wget $NAGIOSPLUGIN
}
nagiosinstall () {
cd $DOWNLOAD_DIR
useradd nagios
/usr/sbin/groupadd nagcmd
/usr/sbin/usermod -a -G nagcmd nagios
/usr/sbin/usermod -a -G nagcmd apache
yum -y install httpd php net-snmp*  mysql-server libdbi-dbd-mysql libdbi-devel php-cli php-mysql gcc glibc glibc-common gd gd-devel php-* perl* make cairo-devel glib2-devel pango-devel openssl* rrdtool* php-gd gd gd-devel gd-progs wget
tar -zxvf nagios-3.4.1.tar.gz
tar -zxvf nagios-plugins-1.4.16.tar.gz
cd nagios
./configure --with-command-group=nagcmd --prefix=$NAGIOSPATH
make all
make install; make install-init; make install-config; make install-commandmode; make install-webconf
echo "Copying Eventhandlers"
cp -R contrib/eventhandlers/ $NAGIOSPATH/libexec/
chown -R nagios:nagios /usr/local/nagios/libexec/eventhandlers
cd ..
cd 	nagios-plugins-1.4.16
./configure --with-nagios-user=nagios --with-nagios-group=nagios --prefix=$NAGIOSPATH
make && make install
chkconfig --add nagios
chkconfig --level 3 nagios on
chkconfig --level 3 httpd on	
htpasswd -s -b -c /opt/nagios/etc/htpasswd.users nagiosadmin nagiosadmin
echo "Please login to http://$HOSTNAME/nagios"
echo "Default username and password is nagiosadmin"
echo /opt/nagios/bin/nagios -v /opt/nagios/etc/nagios.cfg > /sbin/nagioschk
chmod 755 /sbin/nagioschk
/etc/init.d/httpd restart
/etc/init.d/nagios restart
}
case "$1" in
'download')
echo "Downloading Application"
download
;;
'nagiosinstall')
echo "Installing application"
nagiosinstall
;;
*)
echo "Usage: $0 [download|nagiosinstall]"
;;
esac		
		