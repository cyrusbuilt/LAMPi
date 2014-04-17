#!/bin/sh

#  install_phpmyadmin.sh
#  
#
#  Created by Cyrus on 3/18/14.
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
#  SYNOPSIS: Downloads, installs, and configures phpMyAdmin if the user approves.
#

# Adjust URL if necessary
PMA_URL='http://space.dl.sourceforge.net/project/phpmyadmin/4.1.9/phpmyadmin-4.1.9-english.tar.gz'

# Possible return codes.
IPA_CANCEL=0
IPA_CONTINUE=1
IPA_INST_ERR=2

# Ask the user if it is ok to install.
ipa_check_install_phpmyadmin() {
	echo
	echo "This module will install phpMyAdmin in the Apache web content directory."
	echo "ion. If you choose not to install,"
	echo "you will not have web-based administration."
	echo
	local installpma
	while true; do
		read -p "Proceed with phpMyAdmin installation? (Y/n): " installpma
		case installpma in
			[Yy]* ) return 0;;
			[Nn]* ) return 1;;
			* ) echo "Please answer yes or no.";;
		esac
	done
}

# Download the phpMyAdmin package.
ipa_download() {
	echo
	echo "Downloading phpMyAdmin..."
	cd /var/wwww
	wget $PMA_URL
	if [ $? -eq 0 ]; then
		return 0
	fi
	return 1
}

# Extract the package contents into a subdirectory of the apache web root (install).
ipa_extract() {
	local pkg
	echo
	echo "Extracting package files..."
	pkg=phpMyAdmin-4.1.9-english
	tar xvzf $pkg.tar.gz
	mv $pkg pma
	rm -f $pkg.tar.gz
}

# Configure phpAdmin.
ipa_configure() {
	local ipa_conf
	echo
	echo "Configuring phpMyAdmin..."
	cd /var/www/pma
	ipa_conf=config.inc.php
	mv config.sample.inc.php $ipa_conf
	mv $ipa_conf $ipa_conf.old
	sed -i 's/cookie/http/g' $ipa_conf.old > $ipa_conf
	rm -f $ipa_conf.old
}


echo
echo "*********** OPTIONAL: PHPMYADMIN INSTALL **********"
IPA_RET=$IPA_CANCEL
if ipa_check_install_phpmyadmin; then
	if ipa_download; then
		ipa_extract
		ipa_configure
		IPA_RET=$IPA_CONTINUE
		echo "********** PHPMYADMIN INSTALLATION COMPLETE **********"
	else
		IPA_RET=$IPA_INST_ERR
		echo "ERROR: Failed to download phpMyAdmin. Installation FAILED."
	fi
fi

if [ -n "$LAMPI_HOME" ]; then
	cd "$LAMPI_HOME"
else
	cd ~/
fi
exit $IPA_RET