#!/bin/sh

function highlight {
    perl -MTerm::ANSIColor -npe 'BEGIN { %colors = ( PASSED => "green", WARNING => "yellow", ERROR => "red" ) } s/^(PASSED|WARNING|ERROR)/colored([$colors{$1}, "bold"], $1)/ge'
}

ssh -i ~/SailfishOS/vmshare/ssh/private_keys/engine/mersdk mersdk@localhost -p 2222 "cd $(pwd | perl -npe 's{$ENV{HOME}}{/home/mersdk/share}'); rpmvalidation-wrapper.sh -u RPMS/harbour-sudoku*.rpm" | highlight
