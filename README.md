# PentestBox Image Build
This repository contains tools to create a 2GB SD card image based upon latest arch sources including all dependencies for PirateBox.

## The Fork
This is a form from the original PirateBox

## Auto Install script
This build script will ask some very simple questions; the default platform is Raspberry PI 2-3.  All of the other dependencies will be installed automatically.  We have changed some graphics and the footer information so it can be used in a Pentest environment.  Thanks to Kaj for the powerful script.
## Build The RPi Image
Running **make** will acquire all dependencies, install PirateBox and package the image for distribution:
