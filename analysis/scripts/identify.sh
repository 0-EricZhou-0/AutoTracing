#!/bin/bash

# sudo apt-get install cmake ssdeep python3.8 python3.8-dev -y
# python3.8 -m pip install lief python-tlsh pefile

file="/home/yiruiz2/VirtualBoxResources/win10-base-shared/malware/b07d7348d98bef3757914550ba718b8b487d130e390118ce105febd9505f1051.bin.sample"

dname=$(dirname -- "$file")
fname=$(basename -- "$file")
full_dname="$target_dir/$dname"
full_fname="$full_dname/$fname"
mkdir -p "$full_dname"
touch "$full_fname"
md5sum="MD5: $(md5sum $file | cut -d ' ' -f 1)"
sha1sum="SHA1: $(sha1sum $file | cut -d ' ' -f 1)"
sha256sum="SHA256: $(sha256sum $file | cut -d ' ' -f 1)"
# vhash=0
authentihash="AuthentiHash(SHA256): $(python3.8 -c "import lief; print(lief.parse('$file').authentihash(lief.PE.ALGORITHMS.SHA_256).hex())")"
imphash="Imphash: $(python3.8 -c "import pefile; print(pefile.PE('$file').get_imphash())")"
ssdeep="SSDEEP: $(ssdeep "$file" | sed '2p;d' | cut -d ',' -f 1)"
tlsh="TLSH: $(python3.8 -c "import tlsh; print(tlsh.hash(open('$file', 'rb').read()))")"
echo
echo -e "$md5sum"
echo -e "$sha1sum"
echo -e "$sha256sum"
# echo -e "$vhash"
echo -e "$authentihash"
echo -e "$imphash"
echo -e "$ssdeep"
echo -e "$tlsh"
