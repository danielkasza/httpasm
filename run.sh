#!/bin/bash

set -e

if [ `whoami` != "root" ]; then
    echo
    echo "Must be root to run gxemul with TAP network!"
    exit 1
fi

set -x

./gxemul -E oldtestmips -C R3000 httpasm 
