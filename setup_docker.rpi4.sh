#!/bin/bash 

# Set-up docker environment on Raspberry Pi 4
echo "Downloading Docker ..." 
curl -fsSL https://get.docker.com -o get-docker.sh 


echo "Installing Docker ..." 
chmod u+x get-docker.sh
./get-docker.sh 


echo "Adding user to Docker group ..." 
usermod -aG docker $USER 
newgrp docker

echo "Docker is now ready."
