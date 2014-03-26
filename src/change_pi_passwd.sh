#!/bin/sh

#  change_pi_passwd.sh
#  
#
#  Created by Cyrus on 3/16/13.
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
#  SYNOPSIS: Asks the user to change the default pasword for the 'pi' account.
#

# Possible return codes.
CPP_CANCEL=0
CPP_CHANGED=1
CPP_CONTINUE=2

# Ask the user if we can proceed.
function cpp_check_change_passwd() {
	echo
	echo "*********** IMPORTANT **************"
	echo "*                                  *"
	echo "* It is HIGHLY recommended you     *"
	echo "* change your password if you      *"
	echo "* intend to use this system as a   *"
	echo "* web server, particularly if it   *"
	echo "* be exposed to the world.         *"
	echo "*                                  *"
	echo "************************************"
	echo
	local canproceed
	while true; do
		read -p "Proceed with password change? (Y/n): " canproceed
		case canproceed in
			[Yy]* ) return 0;;
			[Nn]* ) return 1;;
			* ) echo "Please answer yes or no.";;
		esac
	done
}

# Check to see if the user wants to quit.
function cpp_check_quit() {
	echo
	local willquit
	while true; do
		read -p "Continue without changing password or quite? (C/q): " willQuit
		case willQuit in
			[Cc]* ) return 0;;
			[Qq]* ) return 1;;
			* ) echo "Please answer 'c' (continue) or 'q' (quit).";;
		esac
	done
}

CPP_RET=$CPP_CANCEL
if cpp_check_change_passwd; then
	sudo -i
	passwd pi
	if [ $? -eq 0 ]; then
		CPP_RET=$CPP_CHANGED
	fi
else
	if cpp_check_quit; then
		CPP_RET=$CPP_CONTINUE
	fi
fi

exit $CPP_RET