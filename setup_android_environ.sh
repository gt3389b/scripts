#! /bin/bash

# Function to switch default the version of GCC
GCC_SWITCH ()
{
	if [ -z "$1" ]; then
		echo "GCC SWITCH requires a GCC version to switch to"
	else
		echo "Switching GCC version to $1"

		sudo rm -f /usr/bin/cpp /usr/bin/gcc /usr/bin/g++	
		sudo ln -s /usr/bin/g++-$1 /usr/bin/g++
		sudo ln -s /usr/bin/gcc-$1 /usr/bin/gcc
		sudo ln -s /usr/bin/cpp-$1 /usr/bin/cpp

		# test if is a 64bit OS; if so then change the 64bit compilers as well
		SIXTYFOUR_BIT=`uname -a | rev | cut -d " " -f 2 | rev`
		if [ "$SIXTYFOUR_BIT" = "x86_64" ]; then
			# 64 bit version
			sudo rm -f /usr/bin/x86_64-linux-gnu-cpp /usr/bin/x86_64-linux-gnu-gcc /usr/bin/x86_64-linux-gnu-g++	
			sudo ln -s /usr/bin/g++-$1 /usr/bin/x86_64-linux-gnu-g++
			sudo ln -s /usr/bin/gcc-$1 /usr/bin/x86_64-linux-gnu-gcc
			sudo ln -s /usr/bin/cpp-$1 /usr/bin/x86_64-linux-gnu-cpp
		fi
	fi

	return 0;
}

UBUNTU_RELEASE=`cat /etc/*-release | grep DISTRIB_RELEASE | rev | cut -d "=" -f 1 | rev`
if [ "$UBUNTU_RELEASE" != "10.04" ]; then

	print "This script requires Ubuntu 10.4 running:" $UBUNTU_RELEASE
	exit;
fi

# create patch
echo "--- sources.list	2010-07-27 21:25:46.048778111 -0400
+++ /etc/apt/sources.list	2010-07-27 21:26:26.800474081 -0400
@@ -51,3 +51,6 @@
 deb-src http://security.ubuntu.com/ubuntu lucid-security universe
 deb http://security.ubuntu.com/ubuntu lucid-security multiverse
 deb-src http://security.ubuntu.com/ubuntu lucid-security multiverse
+
+deb http://us.archive.ubuntu.com/ubuntu karmic multiverse
+deb http://us.archive.ubuntu.com/ubuntu karmic-updates multiverse" > .patch.sources.list

# add older repositories to the source list
read -p "Do you want to update the source list (y/n)?: " CHOICE
if [ "$CHOICE" = "y" ] || [ "$CHOICE" = "Y" ]; then
   sudo patch /etc/apt/sources.list < .patch.sources.list

	# update the sources
	sudo apt-get update
fi

rm .patch.sources.list


# get all the required dependencies
# Android 2.2 does use java6
sudo apt-get install git-core gnupg flex bison gperf libsdl-dev libesd0-dev libwxgtk2.6-dev build-essential zip curl libncurses5-dev zlib1g-dev lib32z1-dev libreadline5-dev g++-multilib gcc-4.3 g++-4.3 gcc-4.3-doc gcc-4.3-locales gcc-4.3-multilib valgrind sun-java6-jdk lib32ncurses5-dev lib32readline5-dev ia32-libs

PATH=$PATH:~/bin
if [ ! -d ~/bin ]; then 
	echo "Creating bin directory"
	mkdir ~/bin; 
fi

if [ ! -f ~/bin/repo ]; then 
	echo "Getting repo from Google"
	curl http://android.git.kernel.org/repo > ~/bin/repo
	chmod a+x ~/bin/repo
fi

if [ ! -d ~/android ]; then 
	echo "Creating android directory"
	mkdir ~/android
fi
if [ ! -d ~/android/platform ]; then 
	echo "Creating android platform directory"
	mkdir ~/android/platform
fi
if [ ! -d ~/android/kernel ]; then 
	echo "Creating android kernel directory"
	mkdir ~/android/kernel
fi
cd ~/android/platform


read -p "Do you want to sync the repository (y/n)?: " CHOICE
if [ "$CHOICE" = "y" ] || [ "$CHOICE" = "Y" ]; then
	echo "Synchronizing Android source"
	repo init -u git://android.git.kernel.org/platform/manifest.git
	repo sync;
fi

GCC_VERSION=`gcc --version | grep gcc | rev | cut -d " " -f 1 | rev`
if [ "$GCC_VERSION" != "4.3.4" ]; then
	echo "Wrong compiler version, switching to 4.3"
	GCC_SWITCH "4.3"
fi

# Create a symbolic link for the 32bit libstdc++
if [ ! -f /usr/lib32/libstdc++.so ]; then 
   echo "Creating symbolic link for 32bit libstdc++"
   sudo ln -s /usr/lib32/libstdc++.so.6 /usr/lib32/libstdc++.so
fi
