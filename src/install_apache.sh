#!/bin/sh

#  install_apache.sh
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
#  SYNOPSIS: Downloads, installs, and configures Apache 2.
#

IA_ERR_SUCCESS=0
IA_ERR_FAILED=1

IA_RET=$IA_ERR_FAILED
IA_SITES='/etc/apache2/sites-enabled'

echo
echo
echo "********* INSTALLING APACHE *********"
echo
sudo apt-get update
sudo apt-get install apache2
IA_ERR=$?
if [ $IA_ERR -eq 100 ]; then
	# apt returned an error. this is not the end of the world
	# if it was just a permissions issue.
	if [ -d $IA_SITES ]; then
		# Looks like install succeeded, but we need to adjust perms.
		echo "Adjusting permissions..."
		sudo groupadd www-data
		sudo usermod -g www-data www-data
		sudo chown -R pi /var/www
	else
		# I take that back... we really did fail.
		echo "Apache installation FAILED."
		exit $IA_ERR_FAILED
	fi
fi

# sed magic to allow override
echo "Configuring Apache..."
DEFAULT_SITE='/etc/apache2/sites-enabled/000-default'
sudo mv $DEFAULT_SITE $DEFAULT_SITE.old
sudo sed 's/AllowOverride None/AllowOverride ALL/g' $DEFAULT_SITE.old > $DEFAULT_SITE
sudo rm -f $DEFAULT_SITE.old

# restart service to apply any changes and return.
echo "Applying changes..."
sudo service apache2 restart
echo
echo "********** APACHE INSTALLATION COMPLETE **********"
exit $IA_RET

