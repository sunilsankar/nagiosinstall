#!/bin/bash
#Author Sunil Sankar
#Date 4 Sep 2012
#Purpose : Installation of Nagios and also intergrate merlin and ninja
DOWNLOAD_DIR=/root/packages
NAGIOSPATH=/opt/nagios
FILE=/root/Nagios.txt
WGET=`/usr/bin/wget`
ADDONS=/opt/nagios/addons
NAGIOSDOWNLOAD=http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-3.4.1.tar.gz
NAGIOSPLUGIN=http://prdownloads.sourceforge.net/sourceforge/nagiosplug/nagios-plugins-1.4.16.tar.gz
LIVESTATUS=http://mathias-kettner.de/download/mk-livestatus-1.2.0p2.tar.gz
MERLIN=git://git.op5.org/nagios/merlin.git
NINJA=git://git.op5.org/nagios/ninja.git
HOSTIPADDRESS=`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`
download () {
mkdir -p $DOWNLOAD_DIR
cd $DOWNLOAD_DIR
echo "Downloading Nagios Core 3.4.1"
wget $NAGIOSDOWNLOAD
echo "Downloading Nagios Plugins 1.4.16"
wget $NAGIOSPLUGIN
echo "Downloading Live Status and check_mk"
wget $LIVESTATUS
}
nagiosinstall () {
cd $DOWNLOAD_DIR
useradd nagios
/usr/sbin/groupadd nagcmd
/usr/sbin/usermod -a -G nagcmd nagios
/usr/sbin/usermod -a -G nagcmd apache
yum -y install httpd php net-snmp*  mysql-server libdbi-dbd-mysql libdbi-devel php-cli php-mysql gcc glibc glibc-common gd gd-devel php-* perl* make cairo-devel glib2-devel pango-devel openssl* rrdtool* php-gd gd gd-devel gd-progs wget MySQL-python gcc-c++ cairo-devel libxml2-devel pango-devel pango libpng-devel freetype freetype-devel libart_lgpl-devel 
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
echo /opt/nagios/bin/nagios -v /opt/nagios/etc/nagios.cfg > /sbin/nagioschk
chmod 755 /sbin/nagioschk
#For running commands from website
/usr/sbin/usermod -a -G nagcmd apache
chmod 775 /opt/nagios/var/rw
chmod g+s /opt/nagios/var/rw
/etc/init.d/httpd restart
/etc/init.d/nagios restart
echo "Nagios and Nagios Plugins installed successfully"
echo "Please access the Nagios Dashboard "
echo "http://$HOSTIPADDRESS/nagios"
echo "Please login with the following Credentials"
echo "USERNAME: nagiosadmin"
echo "PASSWORD: nagiosadmin"
}
livestatusinstall () {
cd $DOWNLOAD_DIR
tar -zxvf mk-livestatus-1.2.0p2.tar.gz
cd mk-livestatus-1.2.0p2
./configure --prefix=$ADDONS/livestatus
make && make install
sed -i '/file!!!/ a\broker_module=/opt/nagios/addons/livestatus/lib/mk-livestatus/livestatus.o /opt/nagios/var/rw/live' /opt/nagios/etc/nagios.cfg
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
'livestatusinstall')
echo "Installing LiveStatus Application"
livestatusinstall
;;
*)
echo "Usage: $0 [download|nagiosinstall|livestatusinstall]"
;;
esac		
		
