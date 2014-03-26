#!/bin/sh

#  install_php5.sh
#  
#
#  Created by Cyrus on 3/17/13.
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
#  SYNOPSIS: Downloads, installs, and configures PHP5.
#

IP5_ERR_SUCCESS=0
IP5_ERR_FAIL=1

IP5_RET=$IP5_ERR_FAIL

echo
echo
echo "********* INSTALLING PHP5 *********"
echo
sudo apt-get install php5 libapache2-mod-php5
if [ $? -eq 0 ]; then
	echo 
	echo "Restarting Apache..."
	sudo service apache2 restart
	IP5_RET=$IP5_ERR_SUCCESS
	echo
	echo "********** PHP5 INSTALLATION COMPLETE ***********"
else
	echo "ERROR: PHP5 installation FAILED."
fi

exit $IP5_RET