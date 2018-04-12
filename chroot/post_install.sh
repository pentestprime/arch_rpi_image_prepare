#!/bin/bash

# dialog --backtitle "PentestBox Post-Installation Script" --title "" \

#Root check!
if [ "$EUID" -ne 0 ]
  then dialog --no-shadow --ascii-lines --colors --msgbox "\Zb\Z1YOU ARE NOT ROOT.  PLEASE RUN THIS SCRIPT AS ROOT." 5 55
  exit 1
fi

dialog --backtitle "PentestBox Post-Installation Script" --title "Welcome!" \
--msgbox "Welcome to the PentestBox! \nWe will now finish the configuration process." \
6 50

dialog --backtitle "PentestBox Post-Installation Script" --title "Passwords" \
--msgbox "Please change the alarm and root user passwords on the following screen."

clear
echo "Changing password for the ALARM user:"
passwd alarm

clear
echo "Changing password for the ROOT user:"
passwd root

exec 4>&1
STORAGE=$(
    dialog \
    --backtitle "PentestBox Post-Installation Script" \
    --title "Select Shared Storage Location"\
    --radiolist "Please choose a location to use as PentestBox storage:" 9 60 2 \
    1 "USB Drive" on \
    2 "MicroSD Card" off 2>&1 1>&4
);
exec 4>&-
echo $STORAGE

exec 4>&1
WIFI=$(
    dialog \
    --backtitle "PentestBox Post-Installation Script" \
    --title "Select Wireless Adapter" \
    --radiolist "Please choose a wireless adapter for the PentestBox network:" 9 65 2 \
    1 "Internal WiFi" on \
    2 "USB WiFi Adapter" off 2>&1 1>&4
);
exec 4>&-
echo $WIFI

bash /opt/piratebox/bin/board-autoconf.sh

(
echo 1
echo XXX; echo 5; echo "Setting up fake time..."; echo XXX
/opt/piratebox/bin/timesave.sh /opt/piratebox/conf/piratebox.conf install
timedatectl set-ntp false
date -s "20170523 1742"
systemctl enable timesave

echo XXX; echo 50; echo "Setting up MiniDLNA..."; echo XXX
cp /etc/minidlna.conf /etc/minidlna.conf.bkp
cp /opt/piratebox/src/linux.example.minidlna.conf /etc/minidlna.conf
systemctl start minidlna
systemctl enable minidlna
echo 100
) | dialog \
--backtitle "PentestBox Post-Installation Script" \
--title "Finishing up..."
--gauge 10 40

dialog --backtitle "PentestBox Post-Installation Script" --title "Configuration Complete!" \
--msgbox "Your PentestBox is now configured!  \nPress OK to reboot." \
6 40
