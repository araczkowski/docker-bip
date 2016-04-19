#!/bin/bash

exec >> >(tee -ai /docker_log.txt)
exec 2>&1

apt-get update && apt-get install -y unzip vim curl

# Download files
echo "--------------------------------------------------"
echo "Downloading all files............................."
./scripts/download_files.sh
#
echo "--------------------------------------------------"
echo "Installing BIP............................."
./scripts/install_bip.sh
#
echo "--------------------------------------------------"
echo "JAVA Policy......................................."
cd $JAVA_HOME/jre/lib/security
echo "grant {" >> java.policy
echo '    permission java.net.SocketPermission "localhost:1527", "listen";' >> java.policy
echo "};" >> java.policy

echo "--------------------------------------------------"
echo "Clean............................................."
echo "Removing temp files"
rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* /files
echo "apt-get clean"
apt-get clean
echo "--------------------------------------------------"
echo "DONE.............................................."
