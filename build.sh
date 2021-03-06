#!/bin/bash

#Check for the presence of dialog
if [ -x "$(command -v dialog)" ]; then
  :
else
  echo "This script uses dialog for a more user-friendly experience.  Install it now? (y/n)"
  read -n 1 install
  case "$install" in
    [yY])
      sudo apt-get install dialog
      ;;
    *)
      echo "But... I need it to run... :-("
      exit 1
      ;;
  esac

fi


dialog --backtitle "PentestBox Build Script" --title "Welcome!" \
--msgbox "Welcome to the PentestBox Build Script. \nPlease ensure that you have made any extra changes you wish to make \nin the ptb-config folder before continuing with this script." \
10 45

#Dialog vars
DIALOG_CANCEL=1
DIALOG_ESC=255
HEIGHT=0
WIDTH=0

#Build vars
DEVICE=2
VERSION=1.1.5+ptb

display_result() {
  dialog --title "$1" \
    --no-collapse \
    --msgbox "$result" 0 0
}

while true; do
  exec 3>&1
  selection=$(dialog \
    --backtitle "PentestBox Build Script" \
    --title "Main Menu" \
    --clear \
    --cancel-label "Exit" \
    --menu "Please select:" $HEIGHT $WIDTH 3 \
    "1" "Select Device Type" \
    "2" "Change Version Number" \
    "3" "Start Build" \
    2>&1 1>&3)
  exit_status=$?
  exec 3>&-
  case $exit_status in
    $DIALOG_CANCEL)
      clear
      echo "Program terminated."
      exit
      ;;
    $DIALOG_ESC)
      clear
      echo "Program aborted." >&2
      exit 1
      ;;
  esac
  case $selection in
    0 )
      clear
      echo "Program terminated."
      ;;
    1 )
        exec 4>&1
        DEVICE=$(dialog \
        --backtitle "PentestBox Build Script" \
        --title "Select Device Type"\
        --radiolist "Select a device:" 10 30 2 \
        1 "Raspberry Pi 1" off \
        2 "Raspberry Pi 2/3" on 2>&1 1>&4);
        exec 4>&-
        echo $DEVICE        
      ;;
    2 )
        exec 4>&1
        VERSION=$(dialog \
        --backtitle "PentestBox Build Script" \
        --title "Change Version Number" \
        --inputbox "Enter a version number for this image:" \
        10 20 "1.1.5+ptb" 2>&1 1>&4);
        exec 4>&-
        echo $VERSION
      ;;
    3 )
        dialog \
        --backtitle "PentestBox Build Script" \
        --title "Build Confirmation" \
        --msgbox "Here is the image we're going to build: \n Device: $DEVICE \n Version: $VERSION" 10 50
        
        clear
        echo "======="
        echo "BUILD PROCESS: 1/2"
        echo "Installing Dependencies"
        echo "======="
        sleep 1
        
        sudo apt-get install pv qemu-system-arm qemu-user-static zip build-essential -y
        sleep 2

        clear
        echo "======="
        echo "BUILD PROCESS: 2/2"
        echo "Building Image"
        echo "======="
        sleep 1       

        make VERSION=$VERSION ARCH=rpi$DEVICE
        sleep 2

        dialog \
        --backtitle "PentestBox Build Script" \
        --title "Build Complete" \
        --msgbox "Assuming there were no errors, \n your image should now be in this directory.  \n Enjoy!" 10 50
        clear
        echo "Have a good day! Thank you for using PentestBox!"
        exit 0
      ;;
  esac
done

