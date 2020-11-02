# References:
# [1] https://github.com/IntelRealSense/librealsense/issues/2586
# [2] https://github.com/IntelRealSense/librealsense/blob/master/doc/installation.md
# 
# https://github.com/Spectator-Health/pyrealsense-docker.git 
#   Attempt at Intel RealSense image on RPi devices 
FROM spectatorhealth/opencv:pi4-py37 

ENV PYTHON_VERSION=3.7 

RUN echo "Installing dependencies ..." && \
	apt-get -y --no-install-recommends update && \
	apt-get -y --no-install-recommends upgrade && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	git libssl-dev libusb-1.0.0-dev pkg-config libgtk-3-dev \
	libglfw3-dev libgl1-mesa-dev libglu1-mesa-dev 

RUN echo "Downloading librealsense ..." && \
	git clone https://github.com/IntelRealSense/librealsense.git

RUN echo "Configuring librealsense ..." && \ 
	cd librealsense && mkdir -p build && cd build && \
	cmake \
		-D CMAKE_BUILD_TYPE=Release \
		-D BUILD_EXAMPLES=true \
		-D BUILD_PYTHON_BINDINGS=bool:true \
		-D PYTHON_EXECUTABLE=$(which python3) .. 

RUN echo "Building librealsense ..." && \
	cd /librealsense/build && make -j$(nproc) && make install 

# NOTE: the dynamic libraries are actually sym links to versioned files; e.g. pyrealsense<...>.so.2.39.1 
RUN echo "Installing Python libraries ..." && \
	cd /librealsense/wrappers/python/pyrealsense2 && \
	ln -s /librealsense/build/wrappers/python/pybackend2.cpython-37m-arm-linux-gnueabihf.so && \
	ln -s /librealsense/build/wrappers/python/pyrealsense2.cpython-37m-arm-linux-gnueabihf.so && \
	cd /usr/local/lib/python3.7/dist-packages && \
	ln -s /librealsense/wrappers/python/pyrealsense2

RUN echo "Verifying RealSense ..." && \
	python3 -c "import pyrealsense2; print('Installed PyRealSense version is: {}'.format(pyrealsense2.pyrealsense2.__version__))" && \
	if [ $? -eq 0 ]; then \
		echo "PyRealSense installed successfully! ..........." \
	else \
		echo "PyRealSense installation failed :( ............" \
		exit 1; \
	fi 

RUN echo "Installation Finished."




