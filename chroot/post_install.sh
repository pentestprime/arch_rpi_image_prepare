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

exec 4>&1
SSID=$(
    dialog \
    --backtitle "PentestBox Post-Installation Script" \
    --title "Choose SSID" \
    --inputbox "Please choose an SSID for the PentestBox's network." \
    8 50 "PentestBox Network" 2>&1 1>&4
);
exec 4>&-
echo $SSID

exec 4>&1
PSK=$(
    dialog \
    --backtitle "PentestBox Post-Installation Script" \
    --title "Enter PSK" \
    --insecure --passwordbox "Please enter a passphrase for the PentestBox's network." \
    8 55 2>&1 1>&4
);
exec 4>&-
echo $PSK

bash /opt/piratebox/bin/board-autoconf.sh

(
echo 1
echo XXX; echo 5; echo "Setting up fake time..."; echo XXX
/opt/piratebox/bin/timesave.sh /opt/piratebox/conf/piratebox.conf install
timedatectl set-ntp false > /dev/null
date -s "20170523 1742"
systemctl enable timesave > /dev/null

echo XXX; echo 10; echo "Configuring WiFi"; echo XXX
case $WIFI in
1)
    echo "wlan0" > /boot/wifi_card.conf
    ;;
2)
    echo "wlan1" > /boot/wifi_card.conf
    ;;
esac

echo XXX; echo 25; echo "Setting SSID/PSK..."; echo XXX

sed -i '3s/.*/ssid=SSS/' /opt/piratebox/conf/hostapd.conf
sed -i "s|SSS|$SSID|g" /opt/piratebox/conf/hostapd.conf
sed -i '23s/.*/wpa_passphrase=PPP/' /opt/piratebox/conf/hostapd.conf
sed -i "s|PPP|$PSK|g" /opt/piratebox/conf/hostapd.conf

echo XXX; echo 50; echo "Setting up storage..."; echo XXX
case $STORAGE in
1)
    bash /opt/piratebox/rpi/bin/usb_share.sh
    ;;
2)
    bash /opt/piratebox/rpi/bin/sdcard_share.sh
    ;;
esac

echo XXX; echo 75; echo "Setting up MiniDLNA..."; echo XXX
cp /etc/minidlna.conf /etc/minidlna.conf.bkp
cp /opt/piratebox/src/linux.example.minidlna.conf /etc/minidlna.conf
systemctl start minidlna
systemctl enable minidlna

echo 100
) | dialog \
--backtitle "PentestBox Post-Installation Script" \
--title "Finishing up..." \
--gauge "Configuring..." 10 40

dialog --stdout --backtitle "PentestBox Post-Installation Script" --title "Configuration Complete!" \
--yesno "Your PentestBox is now configured!  \nWould you like to reboot now?" \
6 40
REBOOT=$?

case $REBOOT in
0)
    dialog --backtitle "PentestBox Post-Installation Script" --title "Configuration Complete!" \
    --msgbox "OK.  Your PentestBox will now reboot..." \
    5 44
    sed -i '12,17d' /etc/motd
    reboot
    ;;
1)
    dialog --backtitle "PentestBox Post-Installation Script" --title "Configuration Complete!" \
    --msgbox "OK.  Be sure to reboot to apply your changes. \nThis script will now exit..." \
    6 50
    exit 0
    ;;
esac

