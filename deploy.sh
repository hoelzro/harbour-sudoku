#!/bin/sh

set -x -e

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

ssh -i /var/extra/SailfishOS/vmshare/ssh/private_keys/engine/mersdk mersdk@localhost -p 2222 "cd $(pwd | perl -npe 's{$ENV{HOME}}{/home/mersdk/share}'); mb2 -t SailfishOS-armv7hl build; mv RPMS/*.rpm /tmp; mb2 -t SailfishOS-i486 build; mv /tmp/*.rpm RPMS"
scp -o ControlPath=/tmp/jolla.sock RPMS/harbour-sudoku*.armv7hl.rpm jolla:
ssh -S /tmp/jolla.sock jolla 'devel-su pkcon --noninteractive install-local harbour-sudoku*.armv7hl.rpm'
