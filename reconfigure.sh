#!/bin/bash

source /home/pi/OpenVPN/vars

if (whiptail --title "Setup OpenVPN" --yesno "You are about to RECONFIGURE your \
Raspberry Pi VPN Server preferences. Are you sure you want to \
continue?" 8 78) then
 	whiptail --title "Setup OpenVPN" --infobox "OpenVPN will be reconfigured." 8 78
else
 	whiptail --title "Setup OpenVPN" --msgbox "Cancelled" 8 78
 	exit
fi

# Ask user for Local IP address or use previous value
if (whiptail --title "Setup OpenVPN" --yesno "Change LOCAL IP? \
	Current: $LOCALIP" 8 78) then
	# Read the local address from the user
	LOCALIP=$(whiptail --inputbox "What is your Raspberry Pi's LOCAL IP address?" \
	8 78 --title "Setup OpenVPN" 3>&1 1>&2 2>&3)
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
	 whiptail --title "Setup OpenVPN" --infobox "Local IP: $LOCALIP" 8 78
	else
	 whiptail --title "Setup OpenVPN" --infobox "Cancelled" 8 78
	 exit
	fi
else
	whiptail --title "Setup OpenVPN" --infobox "Local IP: $LOCALIP" 8 78
fi

# Ask user for Public IP address or use previous value
if (whiptail --title "Setup OpenVPN" --yesno "Change PUBLIC IP? \
	Current: $PUBLICIP" 8 78) then
	# Read the public address from the user
	PUBLICIP=$(whiptail --inputbox "What is your Raspberry Pi's PUBLIC IP address?" \
	8 78 --title "Setup OpenVPN" 3>&1 1>&2 2>&3)
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
	 whiptail --title "Setup OpenVPN" --infobox "PUBLIC IP: $PUBLICIP" 8 78
	else
	 whiptail --title "Setup OpenVPN" --infobox "Cancelled" 8 78
	 exit
	fi
else
	whiptail --title "Setup OpenVPN" --infobox "PUBLIC IP: $PUBLICIP" 8 78
fi

# Ask user for desired level of encryption or use previous value
# if (whiptail --title "Setup OpenVPN" --yesno "Change Encryption Level?" 8 78) then
# 	# Read the local and public IP addresses from the user
# 	PUBLICIP=$(whiptail --inputbox "What is your Raspberry Pi's PUBLIC IP address?" \
# 	8 78 --title "Setup OpenVPN" 3>&1 1>&2 2>&3)
# 	exitstatus=$?
# 	if [ $exitstatus = 0 ]; then
# 	 whiptail --title "Setup OpenVPN" --infobox "PUBLIC IP: $PUBLICIP" 8 78
# 	else
# 	 whiptail --title "Setup OpenVPN" --infobox "Cancelled" 8 78
# 	 exit
# 	fi
# else
# 	whiptail --title "Setup OpenVPN" --infobox "PUBLIC IP: $PUBLICIP" 8 78
# fi
# ENCRYPT=$(whiptail --title "Setup OpenVPN" --menu "Choose your desired level \
# of encryption:" 8 78 2 \
# "1024" "Use 1024-bit encryption. This is faster to set up, but less secure." \
# "2048" "Use 2048-bit encryption. This is much slower to set up, but more secure." \
# 3>&2 2>&1 1>&3)

# Write default file for client .ovpn profiles, to be used by the MakeOVPN script, using template .txt file
sed 's/PUBLICIP/'$PUBLICIP'/' </home/pi/OpenVPN-Setup/Default.txt >/etc/openvpn/easy-rsa/keys/Default.txt

# Write config file for server using the template .txt file
sed 's/LOCALIP/'$LOCALIP'/' </home/pi/OpenVPN-Setup/server_config.txt >/etc/openvpn/server.conf.tmp

# Set previously chosen level of encryption
# KEYLENGTH_REGEX='dh /etc/openvpn/easy-rsa/keys/(.*)\.pem'
# CONFIG_TEXT=$(cat /etc/openvpn/server.conf)

# if [[ $CONFIG_TEXT =~ $KEYLENGTH_REGEX ]]; then
#     i=1
#     n=${#BASH_REMATCH[*]}
#     while [[ $i -lt $n ]]
#     do
#         sed -i "" "s:dh1024:${BASH_REMATCH[$i]}:" /etc/openvpn/server.conf.tmp
# 		break
#     done
# fi

sed -i "" "s:dh1024:dh$ENCRYPT:" /etc/openvpn/server.conf.tmp

# Ask user for DNS Server addresses or use previous value
read -a DNS_ARRAY <<< $DNS_CHOICE
if (whiptail --title "Setup OpenVPN" --yesno "Change DNS servers? \
	Current: $DNS_CHOICE" 8 78) then
	# Read 
	DNS_CHOICE=$(whiptail --inputbox "Which DNS servers do you want to use? \ 
	(separated by spaces)" \
	8 78 --title "Setup OpenVPN" 3>&1 1>&2 2>&3)
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
		read -a DNS_ARRAY <<< $DNS_CHOICE
	else
	 whiptail --title "Setup OpenVPN" --infobox "Cancelled" 8 78
	 exit
	fi
else
	whiptail --title "Setup OpenVPN" --infobox "DNS Servers: $DNS_CHOICE" 8 78
fi

# Set your primary domain name server address(es)
for i in "${DNS_ARRAY[@]}"
do
   echo "push \"dhcp-option DNS $i\"" >> /etc/openvpn/server.conf.tmp
done

# Write remaining config using the second template .txt file
cat /home/pi/OpenVPN-Setup/server_config2.txt >> /etc/openvpn/server.conf.tmp

# Set up logging
if (whiptail --title "Setup OpenVPN" --yesno "Change Logging? \
	Current: $LOGGING" 8 78) then
	# Read
	if (whiptail --title "Setup OpenVPN" --yesno "Do you want logging ENABLED?" 8 78) then
		# if you want logging:
		echo "log /var/log/openvpn.log" >> /etc/openvpn/server.conf.tmp
		echo "status /var/log/openvpn-status.log 20" >> /etc/openvpn/server.conf.tmp
		echo "verb 1" >> /etc/openvpn/server.conf.tmp

		LOGGING="1"
	else
		# if you DONT want logging:
		echo "log /dev/null" >> /etc/openvpn/server.conf.tmp
		echo "status /dev/null" >> /etc/openvpn/server.conf.tmp
		echo "verb 0" >> /etc/openvpn/server.conf.tmp

		LOGGING="0"
	fi
fi
whiptail --title "Setup OpenVPN" --infobox "Logging: $LOGGING" 8 78

# Replace the previous config with the new one
mv /etc/openvpn/server.conf /etc/openvpn/server.conf.prev
mv /etc/openvpn/server.conf.tmp /etc/openvpn/server.conf
rm /etc/openvpn/server.conf.prev

# Write script to run openvpn and allow it through firewall on boot using the template .txt file
sed 's/LOCALIP/'$LOCALIP'/' </home/pi/OpenVPN-Setup/firewall-openvpn-rules.txt >/etc/firewall-openvpn-rules.sh
sudo chmod 700 /etc/firewall-openvpn-rules.sh
sudo chown root /etc/firewall-openvpn-rules.sh

cd /home/pi/OpenVPN
echo "LOCALIP=$LOCALIP" > vars
echo "PUBLICIP=$PUBLICIP" >> vars
echo "DNS_CHOICE=$DNS_CHOICE" >> vars
echo "ENCRYPT=$ENCRYPT" >> vars
echo "LOGGING=$LOGGING" >> vars

whiptail --title "Setup OpenVPN" --msgbox "Configuration complete. Restart \
system to apply changes and start VPN server." 8 78
