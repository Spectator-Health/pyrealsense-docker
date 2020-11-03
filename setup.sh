#!/bin/bash 

# Setup Docker 
sh ./setup_docker.rpi4.sh

# Setup group
echo "Adding user to video group ..." 
usermod -aG video $USER
newgrp video 

echo "Setup complete."  
