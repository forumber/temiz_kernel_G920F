#!/bin/bash
clear

# Initial script by @glewarne big thanks!
# Huge modded by @dorimanx, big thanks to him too!

# location
KERNELDIR=$(readlink -f .);

# Idea by savoca
NR_CPUS=$(grep -c ^processor /proc/cpuinfo)

BUILD_NOW()
{
	# force regeneration of .dtb and zImage files for every compile
	rm -f arch/arm64/boot/*.dtb
	rm -f arch/arm64/boot/*.cmd
	rm -f arch/arm64/boot/Image
	rm -f dt.img
	make zeroflte_02_defconfig

	# remove all old modules before compile
	for i in $(find "$KERNELDIR"/ -name "*.ko"); do
		rm -f "$i";
	done;

	echo "Building kernel with $NR_CPUS CPU threads";

	# build Image
	make -j${NR_CPUS}

	if [ -e "$KERNELDIR"/arch/arm64/boot/Image ]; then
		echo "Create dt.img................"
		./tools/dtbtool -o dt.img -s 2048 -p scripts/dtc/ arch/arm64/boot/dts/

	else
		# with red-color
		echo -e "\e[1;31mKernel STUCK in BUILD! no Image exist\e[m"
	fi;
}

ONLY_DT()
{
	# force regeneration of .dtb and zImage files for every compile
	rm -f arch/arm64/boot/*.dtb
	rm -f arch/arm64/boot/*.cmd
	rm -f dt.img
	make zeroflte_02_defconfig
	make -j${NR_CPUS} dtbs

	./tools/dtbtool -o dt.img -s 2048 -p scripts/dtc/ arch/arm64/boot/dts/

}

CLEAN_KERNEL()
{
    rm -f dt.img
    make clean
    make distclean
    make mrproper
    find . -name "*.dtb" -exec rm {} \;
    find . -type f -name "*~" -exec rm -f {} \;
    find . -type f -name "*orig" -exec rm -f {} \;
    find . -type f -name "*rej" -exec rm -f {} \;
    find . -name "*.ko" -exec rm {} \;
}



echo "Make the kernel, or clean the tree?";
select CHOICE in make make_only_dt clean fresh_make; do
	case "$CHOICE" in
		"make")
			BUILD_NOW;
			break;;
		"make_only_dt")
			ONLY_DT;
			break;;
		"clean")
			CLEAN_KERNEL;
			break;;
		"fresh_make")
			CLEAN_KERNEL;
			BUILD_NOW;
			break;;
	esac;
done;

