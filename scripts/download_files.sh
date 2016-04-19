#!/bin/bash

mkdir /files && cd files

downloadFiles () {

	local url="https://github.com/araczkowski/docker-bip"

	local files=(
    BI_Publisher_Trial_linux_32-64bit_generic.zipaa
    BI_Publisher_Trial_linux_32-64bit_generic.zipab
    BI_Publisher_Trial_linux_32-64bit_generic.zipac
    BI_Publisher_Trial_linux_32-64bit_generic.zipad
    BI_Publisher_Trial_linux_32-64bit_generic.zipae
    BI_Publisher_Trial_linux_32-64bit_generic.zipaf
	)

	local i=1
	for part in "${files[@]}"; do
		echo "[Downloading '$part' (part $i/7)]"
		curl --progress-bar --retry 3 -m 60 -o $part -L $url/blob/master/files/$part?raw=true
		i=$((i + 1))
	done
}

downloadFiles
