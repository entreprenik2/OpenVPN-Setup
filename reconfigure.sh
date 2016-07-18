#!/bin/bash

if (whiptail --title "Setup OpenVPN" --yesno "You are about to RECONFIGURE your \
Raspberry Pi VPN Server preferences. Are you sure you want to \
continue?" 8 78) then
 whiptail --title "Setup OpenVPN" --infobox "OpenVPN will be reconfigured." 8 78
else
 whiptail --title "Setup OpenVPN" --msgbox "Cancelled" 8 78
 exit
fi

# Read the local and public IP addresses from the user
LOCALIP=$(whiptail --inputbox "What is your Raspberry Pi's LOCAL IP address?" \
8 78 --title "Setup OpenVPN" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
 whiptail --title "Setup OpenVPN" --infobox "Local IP: $LOCALIP" 8 78
else
 whiptail --title "Setup OpenVPN" --infobox "Cancelled" 8 78
 exit
fi

# PUBLICIP=$(whiptail --inputbox "What is the public IP address of network the \
# Raspberry Pi is on?" 8 78 --title "OpenVPN Setup" 3>&1 1>&2 2>&3)
# exitstatus=$?
# if [ $exitstatus = 0 ]; then
#  whiptail --title "Setup OpenVPN" --infobox "PUBLIC IP: $PUBLICIP" 8 78
# else
#  whiptail --title "Setup OpenVPN" --infobox "Cancelled" 8 78
#  exit
# fi

# Write default file for client .ovpn profiles, to be used by the MakeOVPN script, using template .txt file
# sed 's/PUBLICIP/'$PUBLICIP'/' </home/pi/OpenVPN-Setup/Default.txt >/etc/openvpn/easy-rsa/keys/Default.txt

# Write config file for server using the template .txt file
sed 's/LOCALIP/'$LOCALIP'/' </home/pi/OpenVPN-Setup/server_config.txt >/etc/openvpn/server.conf.tmp

# Set previously chosen level of encryption
KEYLENGTH_REGEX='dh /etc/openvpn/easy-rsa/keys/(.*)\.pem'
CONFIG_TEXT=$(cat /etc/openvpn/server.conf)

if [[ $CONFIG_TEXT =~ $KEYLENGTH_REGEX ]]; then
    i=1
    n=${#BASH_REMATCH[*]}
    while [[ $i -lt $n ]]
    do
        sed -i "" "s:dh1024:${BASH_REMATCH[$i]}:" /etc/openvpn/server.conf.tmp
		break
    done
fi

# Set your primary domain name server address(es)
DNS_CHOICE=$(whiptail --inputbox "Which DNS servers do you want to use? \ 
(separated by spaces)" \
8 78 --title "Setup OpenVPN" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
	read -a DNS_ARRAY <<< $DNS_CHOICE
	for i in "${DNS_ARRAY[@]}"
	do
	   echo "push \"dhcp-option DNS $i\"" >> /etc/openvpn/server.conf.tmp
	done
else
 whiptail --title "Setup OpenVPN" --infobox "Cancelled" 8 78
 exit
fi

# Write remaining config using the second template .txt file
cat /home/pi/OpenVPN-Setup/server_config2.txt >> /etc/openvpn/server.conf.tmp

# Set up logging
if (whiptail --title "Setup OpenVPN" --yesno "Do you want logging ENABLED? \
continue?" 8 78) then
	cat /home/pi/OpenVPN-Setup/server_config_logging_yes.txt >> /etc/openvpn/server.conf.tmp
else
	cat /home/pi/OpenVPN-Setup/server_config_logging_no.txt >> /etc/openvpn/server.conf.tmp
fi

# Replace the previous config with the new one
cp /etc/openvpn/server.conf /etc/openvpn/server.conf.prev
mv /etc/openvpn/server.conf.tmp /etc/openvpn/server.conf
rm /etc/openvpn/server.conf.prev

# Write script to run openvpn and allow it through firewall on boot using the template .txt file
sed 's/LOCALIP/'$LOCALIP'/' </home/pi/OpenVPN-Setup/firewall-openvpn-rules.txt >/etc/firewall-openvpn-rules.sh
sudo chmod 700 /etc/firewall-openvpn-rules.sh
sudo chown root /etc/firewall-openvpn-rules.sh

whiptail --title "Setup OpenVPN" --msgbox "Configuration complete. Restart \
system to apply changes and start VPN server." 8 78
