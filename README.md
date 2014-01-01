# Sudoku for SailfishOS

This is a Sudoku application for SailfishOS.

# Building & Installing

You can build the application from QtCreator distributed with the Sailfish SDK, or you can build it
from the command line:

## Start the MerSDK Virtual Machine

    user@machine $ VBoxManage startvm MerSDK

## SSH into the MerSDK VM

    user@machine $ ssh -i ~/SailfishOS/vmshare/ssh/private_keys/engine/mersdk mersdk@localhost -p 2222

## Run the build process to generate an RPM

    mersdk@mersdk $ mb2 -t SailfishOS-armv7hl build

## Copy the RPM to your phone

    user@machine $ scp RPMS/harbour-sudoku*.rpm jolla:

## Install on your phone

    root@jolla $ rpm -Uvh harbour-sudoku*.rpm
