#!/bin/bash 
# 
# References: 
# [1] https://github.com/IntelRealSense/librealsense/isues/2586
# [2] https://github.com/IntelRealSense/librealsense/blob/master/doc/installation.md 
# [3] https://github.com/Spectator-Health/pyrealsense-docker.git 

function get_python_site_dir() {
	echo $(python3 -c "import sys; print(sys.path[-1])");
}

function get_python_major() { 
	echo $(python3 -c "import sys; print(sys.version_info[0])"); 
} 

function get_python_minor() {
	echo $(python3 -c "import sys; print(sys.version_info[1])"); 
}

function get_realsense_version() {
	cd ${HOME}/librealsense/build/wrappers/python 
	echo $(python3 -c "import pyrealsense2; print(pyrealsense2.__version__)") 
}

function get_realsense_major() { 
	rs_vers=$(get_realsense_version) 
	IFS='.' 
	read -a vers_coeff <<< "$rs_vers"
	echo ${vers_coeff[0]}
}

function get_realsense_minor() {
	rs_vers=$(get_realsense_version)
	IFS='.'
	read -a vers_coeff <<< "$rs_vers"
	echo ${vers_coeff[1]}
}

PACKAGES=(
	git
	cmake
	openssl
	libusb
	pkg-config
	gtk+3
	glfw
	mesa
)

echo "Install system dependencies ..." && \
	brew update && \
	brew tap homebrew/core && \
	brew install ${PACKAGES[@]}

echo "Cleaning up ..." && \
	brew cleanup 

cd $HOME
echo "Downloading librealsense ..." && \
	git clone https://github.com/IntelRealSense/librealsense.git

echo "Configuring librealsense ..." && \
	cd ${HOME}/librealsense && mkdir -p build && cd build && \
	cmake \
		-D CMAKE_BUILD_TYPE=Release \
		-D BUILD_EXAMPLES=true \
		-D BUILD_PYTHON_BINDINGS=bool:true \
		-D PYTHON_EXECUTABLE=$(which python3) ..

echo "Building librealsense ..." && \
	make -j$(nproc) && make install

# NOTE: the dynamic libraries are actually sym links to versioned files; e.g. pyrealsense<...>.so.2.39.1 
# Use Python system path to determine installation location 
_python_site=$(get_python_site_dir) 
_py_major=$(get_python_major)
_py_minor=$(get_python_minor) 

# Determine RealSense version 
_rs_version=$(get_realsense_version) 
_rs_major=$(get_realsense_major) 
_rs_minor=$(get_realsense_minor) 

# E.g. pybackend2.2.39.0.cpython-39-darwin.so
echo "Installing Python libraries ..." && \
	mkdir ${_python_site}/pyrealsense2 && \
	cd ${_python_site}/pyrealsense2 && \
	mv ${HOME}/librealsense/wrappers/python/pyrealsense2/__init__.py . && \
	mv ${HOME}/librealsense/build/wrappers/python/pybackend2.${_rs_version}.cpython-${_py_major}${_py_minor}-darwin.so . && \
	mv ${HOME}/librealsense/build/wrappers/python/pyrealsense2.${_rs_version}.cpython-${_py_major}${_py_minor}-darwin.so .


echo "Making symbolic links ..." && \
	ln -s pybackend2.${_rs_version}.cpython-${_py_major}${_py_minor}-darwin.so pybackend2.${_rs_major}.cpython-${_py_major}${_py_minor}-darwin.so && \
       	ln -s pybackend2.${_rs_major}.cpython-${_py_major}${_py_minor}-darwin.so pybackend2.cpython-${_py_major}${_py_minor}-darwin.so && \
	ln -s pyrealsense2.${_rs_version}.cpython-${_py_major}${_py_minor}-darwin.so pyrealsense2.${_rs_major}.cpython-${_py_major}${_py_minor}-darwin.so && \
	ln -s pyrealsense2.${_rs_major}.cpython-${_py_major}${_py_minor}-darwin.so pyrealsense2.cpython-${_py_major}${_py_minor}-darwin.so 

echo "Verify PyRealSense ..." && \
	cd ${HOME} && \
	python3 -c "import pyrealsense2; print('Installed PyRealSense version is {}:'.format(pyrealsense2.pyrealsense2.__version__))" && \
	if [ $? -eq 0 ]; then \
		echo "PyRealSense installed successfully .............." \
		echo "Installation complete." \
	else \
		echo "PyRealSense installation failed :( .............." \
		exit 1; \
	fi




