#!/bin/sh

function assert_mer_running {
    VBoxManage list runningvms | grep -q MerSDK || (VBoxManage startvm MerSDK --type=headless ; sleep 30)
}

function assert_jolla_connection {
    if [[ ! -e "/tmp/jolla.sock" ]]; then
        ssh -TNf -S /tmp/jolla.sock jolla
    fi
}

assert_mer_running
assert_jolla_connection

ssh -i ~/SailfishOS/vmshare/ssh/private_keys/engine/mersdk mersdk@localhost -p 2222 "cd $(pwd | perl -npe 's{$ENV{HOME}}{/home/mersdk}'); mb2 -t SailfishOS-armv7hl build"
scp -o ControlPath=/tmp/jolla.sock RPMS/harbour-sudoku*.rpm jolla:
