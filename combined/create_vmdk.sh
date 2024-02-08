#!/bin/bash

if [ $# -ne 1 ]; then
    printf "Usage: %s %s\n" "$0" "<OpenSSD_dev>" 1>&2
    exit 1
fi

OpenSSD_dev=$1

# if ! [ -f "$OpenSSD_dev" ]; then
#     printf "Device %s does not exist\n" "$OpenSSD_dev" 1>&2
#     exit 2
# fi

# hardcoded
target_vmdk="/home/yiruiz2/VirtualBoxResources/OpenSSD.vmdk"

if ! [ -f $target_vmdk ]; then
    sudo VBoxManage internalcommands createrawvmdk -filename "$target_vmdk" -rawdisk "$OpenSSD_dev"
    sudo chown "$USER" "$target_vmdk"
else
    printf "Target <%s> already exists\n" "$target_vmdk"
fi

