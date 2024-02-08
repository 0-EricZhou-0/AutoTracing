#!/bin/bash
sudo nvme admin-passthru /dev/nvme1n1 -o 0x31
sudo nvme admin-passthru /dev/nvme1n1 -o 0x30
