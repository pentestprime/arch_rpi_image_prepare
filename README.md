# PentestBox
This repository contains tools to create a 2GB SD card image based upon the latest Arch Linux sources including all the dependencies 
for PentestBox. PentestBox is a fork of the Piratebox project, intended for use by penetration testers and designed for 
security.

The default network the device creates when it boots is:
```
SSID: PentestBox Network    
PSK: PENTESTBOX    
```
The default credentials to log in to the device, which will have a default IP of 192.168.77.1, are:
```
Username: alarm    
Password: alarm    
```
You will be prompted to change all of these defaults by the post-installation script.

# Building the Image
Run ./build.sh.  The build script will ask some simple questions.  It will then install required dependencies and build the PentestBox image automagically.  

# Credits
Thanks to the PirateBox developers for developing PirateBox.
