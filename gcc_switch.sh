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

GCC_VERSION=`gcc --version | grep gcc | rev | cut -d " " -f 1 | rev`
echo "Currently on GCC version $GCC_VERSION"

echo -n "Which version would you like to switch to [" 
num=0
for i in `ls /usr/bin/gcc-* | sed s/' '/'\\ '/g | rev | cut -d "-" -f 1 | rev`; do
        gcc_vers[$num]=$i
	echo -n " "
        echo -n ${gcc_vers[$num]}
        num=$(($num + 1))
done

read -p " ]? " CHOICE

GCC_SWITCH "$CHOICE"
