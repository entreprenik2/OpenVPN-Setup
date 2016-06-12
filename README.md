OpenVPN-Setup
============

About
-----

Shell script to set up Raspberry Pi (TM) as a VPN server using the free,
open-source OpenVPN software. Includes templates of the necessary configuration
files for easy editing prior to installation, as well as a script for easily
generating client .ovpn profiles after setting up the server.

The master branch of this script installs and configures OpenVPN on Raspbian
Jessie, and should be used if you are running Jessie or Jessie Lite. If you
would like to set up OpenVPN on Raspbian Wheezy, use the Wheezy branch.

Prerequisites
-------------

1. Router forward port 1194
2. [ModMyPi: How to give your Raspberry Pi a Static IP Address](https://www.modmypi.com/blog/tutorial-how-to-give-your-raspberry-pi-a-static-ip-address)

Server-Side Setup
-----------------

You can download the OpenVPN setup script directly through the terminal or SSH using
Git. If you don't already have it, update your APT repositories and install it:

```shell
sudo su
apt-get update
apt-get upgrade
apt-get install git
apt-get install ufw

ufw allow 1194/udp
ufw allow 1194/tcp

ufw enable
```

Then download the latest setup script via the command line with:

```shell
cd
git clone git://github.com/entreprenik2/OpenVPN-Setup
```

Execute the script with:

```shell
cd OpenVPN-Setup
chmod +x openvpnsetup.sh
./openvpnsetup.sh
```

The script will show you a menu of options. If this is your first time running the script,
choose option 01, which will install OpenVPN and configure your system. If you prefer
bypassing the menu and executing scripts directly from the command line, you can instead
install simply by making the script install.sh executable and running it with sudo.

The script will first update your APT repositories, upgrade packages, and install OpenVPN,
which will take some time. It will then ask you to input your Raspberry Pi's local IP
address on your network and the public IP address of your network, and then to choose
which encryption method you wish the guts of your server to use, 1024-bit or 2048-bit.
2048-bit is more secure, but will take much longer to set up. If you're unsure or don't
have a convincing reason for 2048, just choose 1024.

After this, the script will go back to the command line as it builds the server's own
certificate authority. If you wish to enter identifying information for the
CA, replace the default values in the file ca_info.txt (CO for country, ST for
state/province/territory, ORG for organization, etc.) before executing the setup script;
however, this is not required, and you may leave the ca_info.txt file as-is. After this,
the script will prompt you in the command line for input in similar identifying information
fields as it generates your server certificate. Enter whatever you like, or if you do not
desire to fill them out, skip them by pressing enter; make sure to skip the challenge field
and leave it blank. After these fields, you will be asked whether you want to sign the
certificate; you must press 'y'. You'll also be asked if you want to commit - press 'y'
again.

Finally, the script will take some time to build the server's Diffie-Hellman key
exchange. If you chose 1024-bit encryption, this will just take a few minutes, but if you
chose 2048-bit, it will take much longer (anywhere from 40 minutes to several hours on a
Model B+). The script will also make some changes to your system to allow it to forward
internet traffic and allow VPN connections through the Pi's firewall. When the script
informs you that it has finished configuring OpenVPN, reboot the system to apply the
changes, and the VPN server-side setup will be complete!

Making Client Profiles
----------------------

After the server-side setup is finished and the machine rebooted, you may use the MakeOVPN script
to generate the .ovpn profiles you will import on each of your client machines. To generate your
first client profile, execute the openvpnsetup script once again and choose option 02 in the menu,
or else make sure the script MakeOVPN.sh is executable and run it.

You will be prompted to enter a name for your client. Pick anything you like and hit 'enter'.
You will be asked to enter a pass phrase for the client key; make sure it's one you'll remember.
You'll then be prompted for input in more identification fields, which you can again ignore if
you like; make sure you again leave the challenge field blank. The script will then ask if you
want to sign the client certificate and commit; press 'y' for both. You'll then be asked to enter
the pass phrase you just chose in order to encrypt the client key, and immediately after to choose
another pass phrase for the encrypted key - if you're normal, just use the same one. After this,
the script will assemble the client .ovpn file and place it in the directory 'ovpns' within your
home directory.

To generate additional client .ovpn profiles at any time for other devices you'd like to connect
to the VPN, cd into OpenVPN-Setup and execute the setup script, choose menu option 02, and repeat
the above steps for each client.

Removing OpenVPN
----------------

If at any point you wish to remove OpenVPN from your Pi and revert it to a
pre-installation state, such as if you want to undo a failed installation to try again or
you want to remove OpenVPN without installing a fresh Raspbian image, just cd into
OpenVPN-Setup, execute the setup script, and choose option 03, or make sure remove.sh is
executable and run it with sudo.
