#!/bin/sh

#  install_vsftp.sh
#  
#
#  Created by Cyrus on 3/17/14.
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#
#  SYNOPSIS: Downloads, installs, and configures VSFTP if the user approves.
#

# Possible return codes.
IV_CANCEL=0
IV_CONTINUE=1
IV_INST_ERR=2

# Ask the user it is ok install.
function iv_check_install_vsftp() {
	echo
	echo "This module will install the VSFTP server."
	echo "This is an optional installation. If you choose not to install,"
	echo "you will not have standard FTP support."
	echo
	local installftp
	while true; do
		read -p "Proceed with VSFTP installation? (Y/n): " installftp
		case installftp in
			[Yy]* ) return 0;;
			[Nn]* ) return 1;;
			* ) echo "Please answer yes or no.";;
		esac
	done
}

# Configure the daemon.
function iv_config_vsftpd() {
	echo "Configuring VSFTP..."
	VSFTP_CONFIG=/etc/vsftpd.conf
	sudo mv $VSFTP_CONFIG $VSFTP_CONFIG.old
	sudo sed -i 's/anonymous_enable=YES/anonymous_enable=NO/g' $VSFTP_CONFIG.old
	sudo sed -i 's/#local_enable/local_enable/g' $VSFTP_CONFIG.old
	sudo sed -i 's/#write_enable/write_enable/g' $VSFTP_CONFIG.old
	sudo cat $VSFTP_CONFIG.old | sed '$a\force_dot_files=YES' > $VSFTP_CONFIG
	sudo rm -f $VSFTP_CONFIG.old
}

# Restart the daemon to apply the configuration.
function iv_apply_config() {
	echo "Applying configuration..."
	sudo service vsftp restart
}

# Make the user change the root password.
function iv_change_root_passwd() {
	echo "Set new root password:"
	sudo -i
	passwd root
	exit
}

# Modify the local password db.
function iv_modify_passwd_db() {
	echo "Updating password DB..."
	su root << 'EOF'
		PDB=/etc/passwd
		mv $PDB $PDB.old
		sed -i 's/#pi:x/pi:x/g' $PDB.old > $PDB
		rm -f $PDB.old
		usermod -d /var/wwww pi
	EOF

	sudo -i
	usermod -L root
	exit
}


echo
echo "********** OPTIONAL: VSFTP INSTALL **********"
IV_RET=$IV_CANCEL
if iv_check_install_vsftp; then
	sudo apt-get install VSFTP
	if [ $? -eq 0 ]; then
		iv_config_vsftpd
		iv_apply_config
		iv_change_root_passwd
		iv_modify_passwd_db
		IV_RET=$IV_CONTINUE
		echo "********** VSFTP INSTALLATION COMPLETE **********"
	else
		IV_RET=$IV_INST_ERR
		echo "ERROR: VSFTP installation FAILED."
	fi
fi

exit $IV_RET