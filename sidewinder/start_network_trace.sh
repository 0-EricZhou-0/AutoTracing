#!/bin/bash
stdbuf -o0 sudo tcpdump -i eno2 -n 2> /dev/null | stdbuf -i0 -o0 sed -n "s/^\([0-9:\.]*\) IP \([0-9\.]*\) > \([0-9\.]*\).*length \([0-9]*\).*/Time:\1 Src:\2 Dest:\3 Len:\4/p"
