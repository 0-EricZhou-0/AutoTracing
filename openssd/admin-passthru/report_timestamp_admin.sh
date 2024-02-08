#!/bin/bash
sudo nvme admin-passthru /dev/nvme1n1 -o 0x30
