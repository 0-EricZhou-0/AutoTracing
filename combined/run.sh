#!/bin/bash
# set -x
set -e

trap "echo; exit" INT

# VBoxManage clonemedium --format RAW ~/VirtualBox\ VMs/Ubuntu18.04/ubuntu18.04-base/ubuntu18.vdi ~/VirtualBoxResources/ubuntu18.img 
# sudo mount -t 9p -o trans=virtio /mnt/shared /mnt/shared

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
combind_dir="$script_dir"
OpenSSD_dir="$(dirname -- "$combind_dir")/openssd"
sidewinder_dir="$(dirname -- "$combind_dir")/sidewinder"
analysis_dir="$(dirname -- "$combind_dir")/analysis"

data_dir="$analysis_dir/data"
OpenSSD_admin_cmd_dir="$OpenSSD_dir/admin-passthru"

linux_guest_name="ubuntu18.04-raw"
linux_guest_user="platformx"
linux_guest_pswd="19260817"
linux_guest_shared_folder="/mnt/shared"
linux_copied_target_name="~/run"
linux_target_disk_file="/home/yiruiz2/VirtualBoxResources/ubuntu18.img"
linux_bash="/bin/bash"

win_guest_name="win10-raw"
win_guest_user="uiuc-platformx"
win_guest_pswd="UIUCPlatformx"
win_guest_shared_folder="Z:"
win_copied_target_name="C:/Users/uiuc-/Documents/run.exe"
win_target_disk_file="/home/yiruiz2/VirtualBoxResources/win10.img"
win_powershell="C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"

host_shared_folder="/home/yiruiz2/VirtualBoxResources/win10-base-shared"

vt_program="/home/yiruiz2/Downloads/vt-cli/build/vt"
vt_key="816cf78026e3ad8ddaefafe289ce27c68cc80f10a0c5d09449ee29f5a5ec261f"
vt_parser="$script_dir/vt_parser.py"

create_vmdk_program="$combind_dir/create_vmdk.sh"
reset_program="$combind_dir/openssd_autoreboot/reset.sh"
usb_identify_program="$combind_dir/check_usb.sh"
analyze_program="$analysis_dir/analyze.py"

requested_files=( "run.info" "run.info.json" "run.nictrace" "run.ssdtrace" )

# 0b9d33f7a23d2b85a182e80510856f9960cef1554abe358ee6cc14c1516284ac win javascript
# 0e8c99f0e1fd9ea10d561d07a7bb1a0e26b6ae081d1324f5549489e58f4b3255 win javascript
# 198a2d42df010d838b4207f478d885ef36e3db13b1744d673e221b828c28bf77 need glibc 2.27
# 45e51faaaefa2dbcb343a56b2c0be3c64b5fc0010f97a19bedc32d166f200435 win javascript
# 5518f5e20b27a4b10ebc7abce37c733ab532354b5db6aed7edf19c25caba2ff3 win javascript
# 5d7a0823b291315c81e35ed0c7ca7c81c6595c7ca9e5ebf0f56993a02d77c1f2 win javascript
# 658e881da81aaab10873a8a2ade377e1b109b01adeeb4ae74824e6c023e5b198 win javascript
# 6ecf7599637e51186edb088b0b39b592676a6c61c5917ee5c58a64b2ffed0be7 win javascript
# 76a8f6a4577f52cb4fec44745964418d63526e4bc99f9bdd6c5151ea28d834e0 win javascript
# 886c2ca492c3fdbc07ffa66477c671cf016955ac65d3b9cbb3bb5c93b49fbc0a win javascript
# 8b83cbd6a35bbf62bc865b1037db4f3a3b6a35d5be7f99f1db620cc8b7ca1437 win javascript
# b15e87e793fff4465f1f9d8fcc8e89634c0e1b02213a95078919b83420cab7fa win javascript
# bfe88e4229fb197c1b5d8791f068da0f7358b546df7325ec2e266f80a92bdb9b win javascript
# c07e0133de08f88a6a02436e8e8f0e773ee1c68735b98cea1e773ce51c6e695d win javascript
# e1c16f7c77280f307b671baaf7409b6ca7772bcddec3d3bd2b667034df320e27 win javascript
# e248a58ad2c7954d35f9a74d90ec338255cd1852516477494ac57a868df4140b win javascript
# ecc9997b70b8358dddcfe18abf69dfc5974e3cb7971319fe6652af210bb67733 win javascript

declare -A win_targets
win_targets=(
  ["filtered/0b9d33f7a23d2b85a182e80510856f9960cef1554abe358ee6cc14c1516284ac"]="node %s"
  ["filtered/0e8c99f0e1fd9ea10d561d07a7bb1a0e26b6ae081d1324f5549489e58f4b3255"]="node %s"
  ["filtered/45e51faaaefa2dbcb343a56b2c0be3c64b5fc0010f97a19bedc32d166f200435"]="node %s"
  ["filtered/5518f5e20b27a4b10ebc7abce37c733ab532354b5db6aed7edf19c25caba2ff3"]="node %s"
  ["filtered/5d7a0823b291315c81e35ed0c7ca7c81c6595c7ca9e5ebf0f56993a02d77c1f2"]="node %s"
  ["filtered/658e881da81aaab10873a8a2ade377e1b109b01adeeb4ae74824e6c023e5b198"]="node %s"
  ["filtered/6ecf7599637e51186edb088b0b39b592676a6c61c5917ee5c58a64b2ffed0be7"]="node %s"
  ["filtered/76a8f6a4577f52cb4fec44745964418d63526e4bc99f9bdd6c5151ea28d834e0"]="node %s"
  ["filtered/886c2ca492c3fdbc07ffa66477c671cf016955ac65d3b9cbb3bb5c93b49fbc0a"]="node %s"
  ["filtered/8b83cbd6a35bbf62bc865b1037db4f3a3b6a35d5be7f99f1db620cc8b7ca1437"]="node %s"
  ["filtered/b15e87e793fff4465f1f9d8fcc8e89634c0e1b02213a95078919b83420cab7fa"]="node %s"
  ["filtered/bfe88e4229fb197c1b5d8791f068da0f7358b546df7325ec2e266f80a92bdb9b"]="node %s"
  ["filtered/c07e0133de08f88a6a02436e8e8f0e773ee1c68735b98cea1e773ce51c6e695d"]="node %s"
  ["filtered/e1c16f7c77280f307b671baaf7409b6ca7772bcddec3d3bd2b667034df320e27"]="node %s"
  ["filtered/e248a58ad2c7954d35f9a74d90ec338255cd1852516477494ac57a868df4140b"]="node %s"
  ["filtered/ecc9997b70b8358dddcfe18abf69dfc5974e3cb7971319fe6652af210bb67733"]="node %s"
)

win_targets=(
  ["filtered_win/004cdc6996225f244aef124edc72f90434a872b3d4fa56d5ebc2655473733aef"]="%s"
  ["filtered_win/0073e166b46f0be35c6909def0afcddc20f712aaff0e9223ceb36f510d139aef"]="%s"
  ["filtered_win/0084d93f163ea6feddbfe14cda24712494469e1d7d5469d6e4b7867aeb252045"]="%s"
  ["filtered_win/00889f25c5924a45f0f3e56abdd4619d3a5cbbe6a2b816604bbed07d8c2a0ce6"]="%s"
  ["filtered_win/008c3d91f929088631e9cfa0eb61867188b072e6c97d87a39fdf12b2eeae8ba3"]="%s"
  ["filtered_win/00dce1e20b8469aecc0938f2ddec66b813c12dedb50b0b67c3e6a3032c3ca0b0"]="%s"
  # ["filtered_win/01059d48f4547366059d29350932469dc1c1a401e9c90bed5d75251f1368c444"]="%s"
)

# darpa request
win_targets=(
  ["nnn/win/111093146452b46071976d594172bc81d66427651f5f4cc244ddad9b3eae5c7d"]="%s"
  ["nnn/win/19f7d53c4a9ba784fd4c64a06fc6a88caf5a4d9913341a625582d51b1c095ba0"]="%s"
  ["nnn/win/1c2a51daa50a0489a8734d3577b43bcaf78f32ab34a404d2f6026af5ed33cd5b"]="%s"
  ["nnn/win/27389c160ceee51ca1f2b111ca8b221dc75b71cc699789da65802dce082dfbb4"]="%s"
  ["nnn/win/6375e7e4c7cdc3f96afd991c4dfedd5cdfe4b31bf0662dccfa703c117e951f71"]="%s"
  ["nnn/win/7785a14e0b0a09fe2098bc31dae44ce3b3a70854d682316c1bf19b8637dd4056"]="%s"
  ["nnn/win/8958d7b8c51215d6a27444b2760f1ce843a414d380052e6e71c2af6e9ab69ce2"]="%s"
  ["nnn/win/8d62edc1873f8a8b8415bb56d572786a96bd337eaafcf3dbd7666ba4442553fb"]="%s"
  ["nnn/win/a5e6df754a4d3bb72f4d5c91d6b582e7e2c2f87ca838f5d976bc82384a5ad2d1"]="%s"
  ["nnn/win/f3e891a2a39dd948cd85e1c8335a83e640d0987dbd48c16001a02f6b7c1733ae"]="%s"
)

# sudo dpkg --add-architecture i386
# sudo apt-get update
# sudo apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386 libx11-6:i386 -y
# sudo apt-get install libcurl4 curl openssl libcurl3 libcurl-openssl1.0-dev openssh-server

# 198a2d42df010d838b4207f478d885ef36e3db13b1744d673e221b828c28bf77 need glibc 2.27
# 2ace8c4c98c050a9cf57e0e275848c6cf7122f19f4136dabb94a130a88d77997 to test

declare -A linux_targets
linux_targets=(
  ["filtered/00654dd07721e7551641f90cba832e98c0acb030e2848e5efc0e1752c067ec07"]="%s"
  ["filtered/02a5c4aadb7bda35573ee1da564dcd43d7cbe81b58a3060574b736ec63b3cf5c"]="%s"
  ["filtered/02c7cf55fd5c5809ce2dce56085ba43795f2480423a4256537bfdfda0df85592"]="%s"
  ["filtered/04b2309d33e4d2ab06e2d98fe5ec02830a9f85a04ed3cf481b00ebd5443bdec9"]="%s"
  ["filtered/08113ca015468d6c29af4e4e4754c003dacc194ce4a254e15f38060854f18867"]="%s"
  ["filtered/0a76c55fa88d4c134012a5136c09fb938b4be88a382f88bf2804043253b0559f"]="%s"
  ["filtered/0b03c0f3c137dacf8b093638b474f7e662f58fef37d82b835887aca2839f529b"]="%s"
  ["filtered/0b7996bca486575be15e68dba7cbd802b1e5f90436ba23f802da66292c8a055f"]="%s"
  ["filtered/12e0c6242bf530f7de2225ef6426b9a3cfa7788d9171a42aed60f439fb4a3ae8"]="%s"
  ["filtered/1272daef8e1a8143c967676b120cc69be39031efe03593e1006f185e48f428e1"]="%s"
  ["filtered/18abf75790a1cf734b4d4e9e13d9424b015900ebfdec05b85d6980b4742bd879"]="%s"
  ["filtered/1c2b09417c1a34bbbcb8366c2c184cf31353acda0180c92f99828554abf65823"]="%s"
  ["filtered/1d48b36097c12c41611e9dfabfac1d62fce25aeb4c1e7a210d5ca9cfd70e352c"]="%s"
  ["filtered/1d5e4466a6c5723cd30caf8b1c3d33d1a3d4c94c25e2ebe186c02b8b41daf905"]="%s"
  ["filtered/1dc7e88b4bca0d5ae3dfa53104b15e972331549816a020e3ae82f9069abeaca4"]="%s"
  ["filtered/1e7ca210ff7bedeefadb15a9ec5ea68ad9022d0c6f41c4e548ec2e5927026ba4"]="%s"
  ["filtered/1f9c89720e12902168c898d9f56c875a307db1a5a48cba14e6b54a830ad2dc15"]="java -jar %s"
  ["filtered/2a59dd3dfa8b01048d86ef31fa56c12ed501c04e89d8234fab48d3d3774d67bf"]="%s"
  ["filtered/2dabb2c5c04da560a6b56dbaa565d1eab8189d1fa4a85557a22157877065ea08"]="%s"
  ["filtered/2db4adf44b446cdd1989cbc139e67c068716fb76a460654791eef7a959627009"]="%s"
  ["filtered/2e62d6c47c00458da9338c990b095594eceb3994bf96812c329f8326041208e8"]="%s"
  ["filtered/34366a8dab6672a6a93a56af7e27722adc9581a7066f9385cd8fd0feae64d4b0"]="%s"
  ["filtered/345a86f839372db0ee7367be0b9df2d2d844cef406407695a2f869d6b3380ece"]="%s"
  ["filtered/34844e329566572e8ad64a17347a0d842193b42a4dceea2830d8a9722485576b"]="%s"
  ["filtered/35e30d91e405915b2bc9f129befc9f38d4b1694c4223c3bfb4bb8117cfcc4698"]="%s"
  ["filtered/3cad20318f36b020cf4d6b44320eb5a6dae0a78339a0fdc3a1fe5e280a8507f1"]="%s"
  ["filtered/3d375d0ead2b63168de86ca2649360d9dcff75b3e0ffa2cf1e50816ec92b3b7d"]="%s"
  ["filtered/3fe9e1e0a2e626ef10cc443ec1725a8c17cbfa323864e0eb9359399177998470"]="%s"
  ["filtered/44db5b8de39f508bec8e234036f79ae70bca1c117aaf90d82ee53ea37049b348"]="java -jar %s"
  ["filtered/46cf75d7440c30cbfd101dd396bb18dc3ea0b9fe475eb80c4545868aab5c578c"]="%s"
  ["filtered/4b3f7e36e864c21af17bb9a7d0bfecbbbdb0a5fb7b36fa1e86dbb28e159eae04"]="java -jar %s"
  ["filtered/4cffb742e51297c5b5d1c6f785c7125bad60259921e60847ec3246cfeb615410"]="%s"
  ["filtered/5121f08cf8614a65d7a86c2f462c0694c132e2877a7f54ab7fcefd7ee5235a42"]="%s --access-token a"
  ["filtered/5c9b30d502e2f103f089607ce699520f88154e3d7988a9db801f2a2a4378bf41"]="%s"
  ["filtered/5ca4a9f6553fea64ad2c724bf71d0fac2b372f9e7ce2200814c98aac647172fb"]="%s"
  ["filtered/5d51dbf649d34cd6927efdb6ef082f27a6ccb25a92e892800c583a881bbf9415"]="%s"
  ["filtered/5eb4ce37527609e94f7a2b84a8e6248c1fbaa2f36015ec8be74f95a7fb433b86"]="%s"
  ["filtered/5f4593ac397a5bcd8adc97692932b7ab8e63568c635f69f8e93390be38967b07"]="java -jar %s"
  ["filtered/6050a275d31cdf43d32e258ac1d4248b35866948f1bcde90ce5dcb550fea55b7"]="%s"
  ["filtered/652ee7b470c393c1de1dfdcd8cb834ff0dd23c93646739f1f475f71a6c138edd"]="%s"
  ["filtered/6651ce7a82b85ce5e31e367745f754113f9b5ce4dfb0a0b16f4dbcb8dfd7ca1a"]="%s"
  ["filtered/67d9556c695ef6c51abf6fbab17acb3466e3149cf4d20cb64d6d34dc969b6502"]="%s"
  ["filtered/6c12d74a8dbdfc8c39c12a7c1ba861deee6d31f44ea0d812b45846a37ca002b9"]="%s"
  ["filtered/6e21e42cfb93fc2ab77678b040dc673b88af31d78fafe91700c7241337fc5db2"]="%s"
  ["filtered/719e0120cf1e5c0dd80e8e88d9c0c621f8b6f0fd03f7c10758eb453006aecf1f"]="%s"
  ["filtered/74becf0d1621ba1f036025cddffc46d4236530d54d1f913a4d0ad488099913c8"]="%s"
  ["filtered/7b6c17b65a78cda3840e18cb4b78a4b1b3698191aa7160e22d07278ebac60895"]="%s"
  ["filtered/7d1e2685b0971497d75cbc4d4dac7dc104e83b20c2df8615cf5b008dd37caee0"]="%s"
  ["filtered/81d19b8d6a76f8501bbe2f3235821155597c56019eac45da12a5cc3c860fbff8"]="%s"
  ["filtered/83014ab5b3f63b0253cdab6d715f5988ac9014570fa4ab2b267c7cf9ba237d18"]="%s"
  ["filtered/83160da5a4cb335ea2a9a72bc96c833cd7eab9df96a61c1d6f01e13668046b25"]="%s"
  ["filtered/85dc41ca3c16cb0c9de9fe98f73cc86e1a45c21b06d2b502f37d6a8e74974edd"]="%s"
  ["filtered/8c56679d5f3c4ea676da0d8f2b1f77f59102700f0641b30f210183ded0dcabe8"]="%s"
  ["filtered/8fd16e639f99cdaa7a2b730fc9af34a203c41fb353eaa250a536a09caf78253b"]="%s"
  ["filtered/901ca8fe678b8375b60ba9571a4790448bade3b30b5d29665565fcbb1ab5f6ae"]="%s"
  ["filtered/9070f56651f44ec722e17df67b8a954888e387a8f2574594c80937d0f39c471a"]="%s"
  ["filtered/95776f31cbcac08eb3f3e9235d07513a6d7a6bf9f1b7f3d400b2cf0afdb088a7"]="%s --path ."
  ["filtered/9683b04123d7e9fe4c8c26c69b09c2233f7e1440f828837422ce330040782d17"]="%s"
  ["filtered/9f99cf2bdf2e5dbd2ccc3c09ddcc2b4cba11a860b7e74c17a1cdea6910737b11"]="%s"
  ["filtered/ab9cc4ee82aa6f57ba2a113aab905c33e278c969399db4188d0ea5942ad3bb7d"]="%s"
  ["filtered/ac988f2472729c7a01724f28c5fe6b6eba1bc96c07b5af82940a68dbd1eb588a"]="%s"
  ["filtered/ba5b781ebacac07c4b14f9430a23ca0442e294236bd8dd14d1f69c6661551db8"]="%s"
  ["filtered/bbc7202dc3d717baa75282a03be7f01d2adfff533dd4349d9d5205b60b0913a0"]="java -jar %s"
  ["filtered/bcc0a748732e3e8ac08edf26eb5c6350ab11301acfa63375af81ddb756f704d9"]="%s"
  ["filtered/bd7b4c8112eb33fd1d190dda17a63e32206febde20c9f28f4edd14d37afe04a3"]="%s"
  ["filtered/bdcc386efd182fade55b970b1cef775ca28eeb26df928b30deba877bff3744d4"]="%s"
  ["filtered/be15782a7d37e7a1e76f1b4e7aef215b2c65458e0510cdba85999d60b51961c1"]="java -jar %s"
  ["filtered/c0a4f8d6b11d1492b9c0ea5cfff1b732567152e87bcc71694592425e53d520db"]="%s"
  ["filtered/c39b4105e1b9da1a9cccb1dace730b1c146496c591ce0927fb035d48e9cb5c0f"]="%s"
  ["filtered/c3cb84a2511363350d3cbef4343ef86575592637777ae5790189a8e9a4008f42"]="%s"
  ["filtered/c49371cd8dd33f725a780ea179e6281f5cb7f42e84a00836c8fe3350b7b9b2d0"]="%s"
  ["filtered/c721189a2b89cd279e9a033c93b8b5017dc165cba89eff5b8e1b5866195518bc"]="%s"
  ["filtered/c9feac1dfdb3296afc1dca33d24d39ea06ec5e72ad6f781b3ea5be52092e32e5"]="%s"
  ["filtered/d2dc7d49b5fa3f0aa9750db94dfab5f73ff7619fe6aece837b0a0a00726a933a"]="java -jar %s"
  ["filtered/d731ccb407a924ca56fa9b3690e0b7debd1cce61c6de8ec63ede3a992c8af33e"]="%s"
  ["filtered/ddb6b770be043981fdcc1046451be568ca1ee33813bf30e86f647acb77c4236d"]="java -jar %s"
  ["filtered/e1999a3e5a611312e16bb65bb5a880dfedbab8d4d2c0a5d3ed1ed926a3f63e94"]="%s"
  ["filtered/e4d837dc1a700bf71b218e41ed50abdbb2ba0352394504a0cdaa12948d3daf2f"]="%s"
  ["filtered/e5f6fbeb3981c9dfa126dc0a71a0aa41b56a09a89228659a7ea5f32aff4b2058"]="%s"
  ["filtered/e981d507aeb1a553827e895803d946259fedae989c4ebc53ccce558533b3bf91"]="java -jar %s"
  ["filtered/ec22c6e3537fcc0003bb73dd42f41ae077b2cb3ad9cdab295bca46dc91eac1e1"]="%s"
  ["filtered/f2542c584c4236a5135e4048f53fabca349d9f1b8d49a194974631e6b79e0795"]="%s"
  ["filtered/f3a1576837ed56bcf79ff486aadf36e78d624853e9409ec1823a6f46fd0143ea"]="%s"
  ["filtered/f668f74d8808f5658153ff3e6aee8653b6324ada70a4aa2034dfa20d96875836"]="%s -m 50" ######
  ["filtered/f78075951f0272020ca33fee78c3cf9007a0db1842af5cd0eeab518ccc915b16"]="%s"
  ["filtered/f930c00ea8a2feaa9509b474f8905553933d427941664293583b83ca397e575c"]="%s"
  ["filtered/fa00d31583714261640dff4a1262330fe982248cbe11f77953596bd31c979ed9"]="java -jar %s"
  ["filtered/fd8b2ea9a2e8a67e4cb3904b49c789d57ed9b1ce5bebfe54fe3d98214d6a0f61"]="%s"
  ["filtered/fe867904598f271ca6fe92a954fe438d1373b7c4660aa4d851344242b40e3476"]="%s"
  ["filtered/ffe88d3012c15a680a506f0382264ea763ff2d426bf4ad3caf03111d47d9a80c"]="%s"
)

# darpa request
linux_targets=(
  ["filtered/753dc7cd036bdbac772a90fb3478b3ccf22bec70ee4bd2f55dec2041e9482017"]="%s"
  ["filtered/b47d2568947c5a657fd192e4e13feeb23b805e6173fa15b37d6c4c6581c81dfd"]="%s"
  ["filtered/b6844ca4d1d7c07ed349f839c861c940085f1a30bbc3fc4aad0b496e8d492ce0"]="%s"
  ["filtered/b70d14a7c069c2a88a8a55a6a2088aea184f84c0e110678e6a4afa2eb377649f"]="%s"
  ["filtered/bd0141e88a0d56b508bc52db4dab68a49b6027a486e4d9514ec0db006fe71eed"]="%s"
  ["filtered/bd1b8bc046dbf19f8c9bbf9398fdbc47c777e1d9e6d9ff1787ada05ed75c1b12"]="%s"
  ["filtered/e024ccc4c72eb5813cc2b6db7975e4750337a1cc619d7339b21fdbb32d93fd85"]="%s"
  ["filtered/f4a64ab3ffc0b4a94fd07a55565f24915b7a1aaec58454df5e47d8f8a2eec22a"]="%s"
)

# darpa request
linux_targets=(
  ["filtered/0ff70de135cee727eca5780621ba05a6ce215ad4c759b3a096dd5ece1ac3d378"]="%s" # No such file or directory
  ["filtered/10c7e04d12647107e7abf29ae612c1d0e76a79447e03393fa8a44f8a164b723d"]="%s" # cannot execute binary file: Exec format error
  ["filtered/13cbde1b79ca195a06697df937580c82c0e1cd90cc91c18ddfe4a7802e8e923a"]="%s" # No such file or directory
  ["filtered/198a2d42df010d838b4207f478d885ef36e3db13b1744d673e221b828c28bf77"]="%s" # Error loading Python lib '/tmp/_MEIQalfS4/libpython3.9.so.1.0': dlopen: /lib/x86_64-linux-gnu/libm.so.6
  ["filtered/1a7316d9bb8449cf93a19925c470cc4dbfd95a99c03b10f4038bb2a517d6ed50"]="%s" # No such file or directory
  ["filtered/1c55ffee91e8d8d7a1b4a1290d92a58c4da0c509d5d8d2741cec7f4cf6a099bd"]="%s" # [1]    1880 segmentation fault (core dumped)
  ["filtered/294b8db1f2702b60fb2e42fdc50c2cee6a5046112da9a5703a548a4fa50477bc"]="%s" # error while loading shared libraries: libssl.so.10
  ["filtered/2e52494e776be6433c89d5853f02b536f7da56e94bbe86ae4cc782f85bed2c4b"]="%s" # !error: no flag -u <login>:<password> provided
  ["filtered/331494780c1869e8367c3e16a2b99aeadc604c73b87f09a01dda00ade686675b"]="%s" # interactive terminal display
  ["filtered/40b5127c8cf9d6bec4dbeb61ba766a95c7b2d0cafafcb82ede5a3a679a3e3020"]="%s" # [1]    2088 segmentation fault (core dumped)
  ["filtered/427a0860365f15c1408708c2d6ed527e4e12ad917a1fa111d190c6601148a1eb"]="%s" # error while loading shared libraries: libpcap.so.1
  ["filtered/4b0cc15b24e38ec14e6d044583992626dd8c72a4255b9614be46b1b4eefa41d7"]="%s" # Bad arg length for Socket::pack_sockaddr_in, length is 0, should be 4 at /usr/lib/x86_64-linux-gnu/perl/5.26/Socket.pm line 157.
  ["filtered/552245645cc49087dfbc827d069fa678626b946f4b71cb35fa4a49becd971363"]="%s" # error args, exit
  ["filtered/5a1a0fe128e5e110570391c80a36d535a5a54af0dcb808d53e4eb1532344df99"]="%s" # error while loading shared libraries: libssl.so.10
  ["filtered/6552421ab17ee017b2a3942400c45d11423459ea8d39e58821330d7d58a79ce3"]="%s" # /bin/sh: ./a.out: not found
  ["filtered/669119b2a9d5b6e1b764acf7582574345ff5470d8717da53a8330f358ffb8904"]="%s" # [1]    2162 segmentation fault (core dumped)
  ["filtered/7eaf3408cc13b8c36fafbdc0343053e82fb647b0b64e63a99bb0e90ba47c13a6"]="%s" # [1]    2183 segmentation fault (core dumped)
  ["filtered/8195dd41344c769364ee0c00c73aa65a60921e6b3281423aa93946b58889d8bd"]="%s" # exit with return value 1 immediately
  ["filtered/8426362268549f8b69bf7ffdd070d0ef9e24f5ea69df27ff39a60d1ab5ec8355"]="%s" # Segmentation fault (core dumped)
  ["filtered/8e7cd7bfc2ad7810b073839e1933518b7a40b083297e0d9828a4b885fb1df5fe"]="%s" # GUI presented
  ["filtered/93f4262fce8c6b4f8e239c35a0679fbbbb722141b95a5f2af53a2bcafe4edd1c"]="%s" # a newline character printed
  ["filtered/96339a7e87ffce6ced247feb9b4cb7c05b83ca315976a9522155bad726b8e5be"]="%s" # DECRYPTION Path not exists in this system
  ["filtered/969d4bb4a2c9c343a2b4c7ebe416bced980cb12979047065d9262b798d02b0af"]="%s" # [1]    2317 segmentation fault (core dumped)
  ["filtered/970b49c16eebd558ac8984643f3763e76a52c9be4118f9e5830b8f5c406414fc"]="%s" # [1]    2327 segmentation fault (core dumped)
  ["filtered/acd07de34cc15f49fd919dc18e695632a08a132fcfc4e9b6292e1a0d45e953e5"]="%s" # error while loading shared libraries: libpcap.so.1
  ["filtered/ad6ff2ea0ba3e84091db12652080fe9fc35647f1e89d1c13df0e39abceaac8fe"]="%s" # error while loading shared libraries: libcurl.so.4
  ["filtered/ae9d6848f33644795a0cc3928a76ea194b99da3c10f802db22034d9f695a0c23"]="%s" # exit with return value 1 immediately
  ["filtered/b513d65d0d18d924b264815275ffa941e89d6b72d9744f9a5115ca4b28ce49f9"]="%s" # plain text
  ["filtered/b90b8a4cfbf8fd6de68257528cd01a5cdb6d3d6ce93cc009498a0fc751ce01fd"]="%s" # [1]    2484 segmentation fault (core dumped)
  ["filtered/c93e6237abf041bc2530ccb510dd016ef1cc6847d43bf023351dce2a96fdc33b"]="%s" # [1]    6440 segmentation fault (core dumped)
  ["filtered/cc6eec967f1f28dfe9dcd995293b3e2c3d94fd0610ba57d8fbec4180b948145b"]="%s" # cannot execute binary file: Exec format error
  ["filtered/d51cb52136931af5ebd8628b64d6cd1327a99196b102d246f52d878ffb581983"]="%s" # error while loading shared libraries: libfipscheck.so.1
  ["filtered/d7d1257a8a7dc21eb82715b70c6f4177f515963aec4bd1bdecdf1cd164fcd5ef"]="%s" # error while loading shared libraries: libpng12.so.0
  ["filtered/dca08fe4c7bceb5df6b189f59e57e4c984bb799e9636fa8dbbe0d010b90b7145"]="%s" # ERROR : connect() Error Number : 111 Error Message : Connection refused
  ["filtered/e9687f668601bb865da0e16de7e03bb3d723ca5d109183987fc263a99ff3fe2a"]="%s" # Usage: decrypt.elf full path to filename to decrypt
  ["filtered/e9e2e84ed423bfc8e82eb434cede5c9568ab44e7af410a85e5d5eb24b1e622e3"]="%s" # Segmentation fault (core dumped)
)

# darpa request
linux_targets=(
  ["nnn/linux/2c14356e0a6a9019c50b069e88fe58abbbc3c93451a74e3e66f8c1a2a831e9ba"]="%s"
  ["nnn/linux/67df6effa1d1d0690c0a7580598f6d05057c99014fcbfe9c225faae59b9a3224"]="%s"
  ["nnn/linux/f3a1576837ed56bcf79ff486aadf36e78d624853e9409ec1823a6f46fd0143ea"]="%s"
)

# pretty printing
time_print_interval () {
  total_time="$1"
  interval="$2"
  current_time=0
  while [ "$current_time" -lt "$total_time" ]; do
    sleep_time=$(("$total_time" - "$current_time"))
    sleep_time=$(("$sleep_time" > "$interval" ? "$interval" : "$sleep_time"))
    echo "$current_time/$total_time sleep $sleep_time"
    sleep "$sleep_time"
    current_time=$(("$current_time" + "$interval"))
  done
} 

# determine all connected usb devices
# FIXME: This could potentially change if host machine configuration is modified.
usb_devs=$("$usb_identify_program" | grep ttyUSB)

# parse for all device JTAG and UART
peripherals_exist=0
prog_peripherals_exist=0
aux_peripherals_exist=0
OpenSSD_JTAG=""
OpenSSD_UART=""
ESP32_UART=""
readarray -t usb_mappings_pre_parse <<<"$usb_devs"
for usb_mapping in "${usb_mappings_pre_parse[@]}"; do
  IFS='<' read -ra usb_mapping <<< "$usb_mapping"
  dev="${usb_mapping[0]}"
  desc="${usb_mapping[1]}"
  if [[ "$desc" =~ "Digilent" ]]; then 
    OpenSSD_JTAG="$dev"
    prog_peripherals_exist=$(( peripherals_exist + 1 ))
  elif [[ "$desc" =~ "CP2103" ]]; then 
    OpenSSD_UART="$dev"
    peripherals_exist=$(( peripherals_exist + 1 ))
  elif [[ "$desc" =~ "CP2102" ]]; then 
    ESP32_UART="$dev"
    aux_peripherals_exist=$(( peripherals_exist + 1 ))
  fi
done

# parse for all device
OpenSSD_dev="$(lsblk -o NAME,MODEL | grep OpenSSD | awk '{print $1}')"
if [ -n "$OpenSSD_dev" ]; then
  OpenSSD_dev="/dev/$OpenSSD_dev"
  peripherals_exist=$(( peripherals_exist + 1 ))
fi

# parse input arguments
DRY_RUN=0
MANUAL_MODE=0
REPORT_STAT=0
while getopts "hurdsm:" arg; do
  case $arg in
    h)
      printf "Usage: %s:\n" "$1" >&2
      printf "Tracing facility\n" >&2
      printf "  -h               print help, this message\n" >&2
      printf "  -u               report required and connected peripherals\n" >&2
      printf "  -r               system reset and reprogram\n" >&2
      printf "  -d               dry run, display what the script would do without actual action\n" >&2
      printf "  -s               dry run with script status report, for connecting with auto-run script via ssd\n" >&2
      printf "  -m [SAMPLE_NAME] manual mode, specify the same name\n" >&2
      printf "Return values\n" >&2
      printf "  0                script terminates successfully\n" >&2
      printf "  1                invalid options\n" >&2
      printf "  2                abort on necessary peripherals are not connected/detected\n" >&2
      printf "  255              abort on internal script errors\n" >&2
      ;;
    u)
      printf "OpenSSD JTAG @ %s\n" "$OpenSSD_JTAG"
      printf "OpenSSD UART @ %s\n" "$OpenSSD_UART"
      printf "ESP32 UART   @ %s\n" "$ESP32_UART"
      printf "OpenSSD Dev  @ %s\n" "$OpenSSD_dev"
      exit 0
    ;;
    r)
      "$reset_program" "$ESP32_UART" "$OpenSSD_UART"
      exit 0
    ;;
    d)
      DRY_RUN=1
    ;;
    s)
      DRY_RUN=1
      REPORT_STAT=1
    ;;
    m)
      MANUAL_MODE=1
      manual_sample_name=$(basename -- "${OPTARG}")
      platform=$(dirname -- "${OPTARG}")
      [ "$platform" == "linux" ] || [ "$platform" == "win" ] || exit 1
    ;;
    *)
      exit 1
    ;;
  esac
done

# determine run target
RET_VAL=0
if [ "$MANUAL_MODE" -eq 0 ]; then
  # get all targets needed to run, sort them according to alphabetical order
  all_targets=( "${!linux_targets[@]}" "${!win_targets[@]}" )
  IFS=$'\n' targets_sorted=($(sort <<< "${all_targets[*]}"))
  unset IFS


  run_target=""
  platform=""
  for target in "${targets_sorted[@]}"; do
    target_name=$(basename "$target")
    target_folder="$data_dir/$target_name"
    if ! [ -f "$host_shared_folder/$target" ]; then
      if [ "$REPORT_STAT" -eq 0 ]; then
        printf "test file <%s> does not exist\n" "$host_shared_folder/$target"
      fi
      continue
    fi
    if [ -d "$target_folder" ]; then
      for requested_file in "${requested_files[@]}"; do
        if ! [ -f "$target_folder/$requested_file" ]; then 
          if [ "$REPORT_STAT" -eq 0 ]; then
            printf "<%s> does not exist\n" "$target_folder/$requested_file"
          fi
          run_target="$target"
          break
        fi
      done
      if [ -n "$run_target" ]; then
        break
      fi
    else
      run_target="$target"
      break
    fi
  done

  # determine the sample to run, and the platform that the sample is on
  target="$run_target"
  if [[ -v "linux_targets[$target]" ]]; then 
    platform="linux"
  elif [[ -v "win_targets[$target]" ]]; then
    platform="win"
  fi
else
  # name target after user specification
  target="manual/$manual_sample_name"
fi

# if -s is specified, print return value before exit
# output status using stdout instead of return value
# FIXME: Getting the return value from ssh session is possible
if [ "$REPORT_STAT" -ne 0 ]; then
  if [ "$peripherals_exist" -lt 2 ]; then
    printf 2
  elif [ -z "$platform" ] || [ -z "$target" ]; then
    printf 1
  else
    printf 0
  fi
  exit
fi

# set running command
if [ "$platform" == "linux" ]; then
  cmd_str="${linux_targets[$target]}"
  printf -v run_command "$cmd_str" "$linux_copied_target_name"
elif [ "$platform" == "win" ]; then
  cmd_str="${win_targets[$target]}"
  printf -v run_command "$cmd_str" "$win_copied_target_name"
fi

# report target to stdout if it exists
if [ -n "$target" ]; then
  echo "Running target <$target> @ platform <$platform>"
  printf "Command to run <%s>\n" "$run_command"
fi

# if -d is specified or error encountered, return immediately
if [ "$DRY_RUN" -ne 0 ] || [ "$RET_VAL" -ne 0 ]; then
  exit "$RET_VAL"
fi

# sanity check
if [ "$peripherals_exist" -lt 2 ]; then 
  printf "Not all peripherals connected\n"
  printf "Status:\n"
  printf "  OpenSSD JTAG Programmer: %s\n" "$OpenSSD_JTAG"
  printf "  OpenSSD UART           : %s\n" "$OpenSSD_UART"
  printf "  ESP32 UART             : %s\n" "$ESP32_UART"
  printf "  OpenSSD dev            : %s\n" "$OpenSSD_dev"
  exit 2
fi
if [ -z "$platform" ]; then 
  printf "Target <%s> should exist but actually not, check input array format\n" "$target" >&2
  exit 255
fi

target_name=$(basename "$target")
target_folder="$data_dir/$target_name"

nictrace_file="$target_name.nictrace"
ssdtrace_file="$target_name.ssdtrace"
info_file="$target_name.info"
info_file_json="$target_name.json"
info_file_timing="$target_name.info.timing"

temp_nictrace_file="$HOME/$nictrace_file"
temp_ssdtrace_file="$HOME/$ssdtrace_file"
temp_info_file="$HOME/$info_file"
temp_info_file_timing="$HOME/$info_file_timing"
temp_info_file_json="$HOME/$info_file_json"

mkdir -p "$target_folder"

# get sample info from virustotal and parse the result
cat /dev/null > "$temp_info_file"
if [ "$MANUAL_MODE" -eq 0 ]; then
  set +e
  "$vt_program" -k "$vt_key" file "$target_name" --format json > "$temp_info_file_json"
  if [ $? -ne 0 ]; then
    printf "VT not responding, manaul checking required\n" >&2
    exit 255
  fi
  python3 "$vt_parser" "$temp_info_file_json" > "$temp_info_file" 2> /dev/null
  if [ $? -ne 0 ]; then 
    printf "JSON info parse error\n"
  fi
  set -e
  printf "Info retrieve and parse done\n"
else
  echo "Manual sample: $manual_sample_name" > "$temp_info_file"
fi
# initialize resources
"$create_vmdk_program" "$OpenSSD_dev"
if [ "$platform" == "linux" ]; then
  guest_name="$linux_guest_name"
  target_disk_file="$linux_target_disk_file"
elif [ "$platform" == "win" ]; then
  guest_name="$win_guest_name"
  target_disk_file="$win_target_disk_file"
fi
# add NIC trace, to be changed in future
vboxmanage modifyvm "$guest_name" --nictrace1 on --nictracefile1 "$temp_nictrace_file"
# overwrite OpenSSD
sudo dd bs=4M if="$target_disk_file" of="$OpenSSD_dev" status=progress oflag=sync

# open trace and start VM
sudo "$OpenSSD_admin_cmd_dir/start_trace_admin.sh"
vboxmanage startvm "$guest_name" --type headless
boottime=$(sudo "$OpenSSD_admin_cmd_dir/get_timestamp_millisec.sh")
echo "boot time: $boottime ms" >> "$temp_info_file_timing"
printf "VM boot @ %d\n" "$boottime"

if [ "$platform" == "linux" ]; then
  # wait for Ubuntu boot and wait for initial I/O operation to die down
  time_print_interval 400 30
elif [ "$platform" == "win" ]; then
  # wait for Ubuntu boot and wait for initial I/O operation to die down
  time_print_interval 600 30
fi

# pick ransomware from storage, copy to VM home
set -x
if [ "$MANUAL_MODE" -ne 0 ]; then
  :
elif [ "$platform" == "linux" ]; then
  vboxmanage guestcontrol "$linux_guest_name" --username "$linux_guest_user" --password "$linux_guest_pswd" run -- "$linux_bash" -c "cp $linux_guest_shared_folder/$target $linux_copied_target_name; chmod +x $linux_copied_target_name"
elif [ "$platform" == "win" ]; then
  vboxmanage guestcontrol "$win_guest_name" --username "$win_guest_user" --password "$win_guest_pswd" run -- "$win_powershell" /c "cp $win_guest_shared_folder/$target $win_copied_target_name"
fi

# record current timestamp
starttime=$(sudo "$OpenSSD_admin_cmd_dir/get_timestamp_millisec.sh")
echo "start time: $starttime ms" >> "$temp_info_file_timing"
# start execution
if [ "$MANUAL_MODE" -ne 0 ]; then
  echo "Please Perform Manual Action"
elif [ "$platform" == "linux" ]; then
  timeout -k 0s 1400s vboxmanage guestcontrol "$linux_guest_name" --username "$linux_guest_user" --password "$linux_guest_pswd" run -- "$linux_bash" -c "sudo $run_command" > /dev/null 2>&1 &
elif [ "$platform" == "win" ]; then
  timeout -k 0s 1400s vboxmanage guestcontrol "$win_guest_name" --username "$win_guest_user" --password "$win_guest_pswd" run -- "$win_powershell" /c "$run_command" # > /dev/null 2>&1 &
fi
printf "Sample start @ %d\n" "$starttime"
set +x
# wait for execution to finish
time_print_interval 1200 30
# time_print_interval 500 30
set -x
endtime=$(sudo "$OpenSSD_admin_cmd_dir/get_timestamp_millisec.sh")
echo "end time: $endtime ms" >> "$temp_info_file_timing"
printf "VM destroyed @ %d\n" "$endtime"
blks=$(sudo "$OpenSSD_admin_cmd_dir/end_trace_admin.sh")
set +x
# poweroff VM
if [ "$platform" == "linux" ]; then
  vboxmanage controlvm "$linux_guest_name" poweroff
elif [ "$platform" == "win" ]; then
  vboxmanage controlvm "$win_guest_name" poweroff
fi
printf "VM poweroff\n"

# collect trace
cat "$temp_info_file_timing" >> "$temp_info_file"
cp "$temp_nictrace_file" "$target_folder/run.nictrace"
sudo "$OpenSSD_dir/read_trace" "$blks" > "$temp_ssdtrace_file"
cp "$temp_ssdtrace_file" "$target_folder/run.ssdtrace"
cp "$temp_info_file" "$target_folder/run.info"
cp "$temp_info_file_timing" "$target_folder/run.info.timing"
if [ "$MANUAL_MODE" -eq 0 ]; then
  cp "$temp_info_file_json" "$target_folder/run.info.json"
else
  :
fi
printf "Trace done\n"

backup_folder="$HOME/trace_backup"
mkdir -p "$backup_folder"
mv "$temp_nictrace_file" "$backup_folder/$nictrace_file"
mv "$temp_ssdtrace_file" "$backup_folder/$ssdtrace_file"
mv "$temp_info_file" "$backup_folder/$info_file"
mv "$temp_info_file_timing" "$backup_folder/$info_file_timing"
if [ "$MANUAL_MODE" -eq 0 ]; then
  mv "$temp_info_file_json" "$backup_folder/$info_file_json"
else
  :
fi
printf "Backup done\n"

# try analyze the data
"$analyze_program" "$target_name"
printf "Analyze done\n"

# reset trace buffer
"$reset_program" "$ESP32_UART" "$OpenSSD_UART"
sleep 10
# sudo reboot

