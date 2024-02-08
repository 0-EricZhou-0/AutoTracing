#!/bin/bash
sudo nvme admin-passthru /dev/nvme1n1 -o 0x22 2>&1 | sed -rn "s/NVMe command result:/0x/p" | xargs printf "%d"
