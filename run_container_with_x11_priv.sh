#! /bin/sh 
xhost +local:root 

docker run \
	--rm  `# delete container when bash exits` \
	-it `# connect TTY` \
	--network=host \
	--env="DISPLAY=$DISPLAY"  `# export DISPLAY env variable for X server` \
	--env="QT_GRAPHICSSYSTEM=native" \
	--env="QT_X11_NO_MITSHM=1" \
	--privileged \
	--volume="$HOME/.Xauthority:/root/.Xauthority"  `# provide authority information to X server` \
	--volume="/tmp/.X11-unix:/tmp/.X11-unix:rw"  `# mount the X11 socker` \
	--volume="/dev:/dev" `# enable access to USB (req'd for Intel camera device)` \
	--volume="/lib/modules:/lib/modules" \
	--cap-add=ALL \
	$1 `# additional CLI arguments (e.g. additional volumes to mount)` \
	spectatorhealth/realsense:pi4-py37 bash -il 

xhost -local:root
	
