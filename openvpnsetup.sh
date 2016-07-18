#!/bin/bash

askreboot() {
	if (whiptail --title "Reboot" --yesno --defaultno "Would you like to reboot now?" 8 78) then
		whiptail --title "Reboot" --msgbox "The system will reboot." 8 78
		reboot
	fi
}


exitstatus=0
while [ $exitstatus = 0 ]
do
	CHOICE=$(whiptail --title "OpenVPN-Setup" --menu "Setup options:" 16 78 4 \
	"01" "Setup OpenVPN on your system" \
	"01" "RECONFIGURE OpenVPN on your system" \
	"03" "Generate a client profile with MakeOVPN" \
	"04" "Remove OpenVPN and revert your system to a pre-installation state" 3>&2 2>&1 1>&3)

	case "${CHOICE}" in
		01)
			sudo chmod +x install.sh
			sudo ./install.sh
			askreboot
		;;
		01)
			sudo chmod +x reconfigure.sh
			sudo ./reconfigure.sh
			askreboot
		;;
		03)
			./MakeOVPN.sh
		;;
		04)
			sudo ./remove.sh
			askreboot
		;;
		*)
			exitstatus=1
			exit
		;;
	esac
done
