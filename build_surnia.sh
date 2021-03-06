 #
 # Copyright � 2016,  Sultan Qasim Khan <sultanqasim@gmail.com> 	
 # Copyright � 2016,  Zeeshan Hussain <zeeshanhussain12@gmail.com> 	      
 # Copyright � 2016,  Varun Chitre  <varun.chitre15@gmail.com>	
 #
 # Custom build script
 #
 # This software is licensed under the terms of the GNU General Public
 # License version 2, as published by the Free Software Foundation, and
 # may be copied, distributed, and modified under those terms.
 #
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 #
 # Please maintain this if you use this script or any part of it
 #

# Define variables
Toolchain="/home/christian/uber-5.2/bin/arm-eabi-"
Kernel_Dir="/home/christian/chriszuma-msm8916"
KERNEL="/home/christian/chriszuma-msm8916/arch/arm/boot/zImage"
Dtbtool="/home/christian/chriszuma-msm8916/tools/dtbToolCM"

#!/bin/bash
BUILD_START=$(date +"%s")
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'
export ARCH=arm
export SUBARCH=arm
export CROSS_COMPILE=$Toolchain
export KBUILD_BUILD_USER="christian"
export KBUILD_BUILD_HOST="zeeshan"
echo -e "$red***********************************************"
echo "          Compiling Chriszuma kernel          "
echo -e "***********************************************$nocol"
rm -f arch/arm/boot/dts/*.dtb
rm -f arch/arm/boot/dt.img
rm -f cwm_flash_zip/boot.img
echo -e " Initializing defconfig"
make surnia_defconfig
echo -e " Building kernel"
make -j4 zImage
make -j4 dtbs

$Dtbtool -2 -o $Kernel_Dir/arch/arm/boot/dt.img -s 2048 -p $Kernel_Dir/scripts/dtc/ $Kernel_Dir/arch/arm/boot/dts/

make -j4 modules
if [ -a $KERNEL ];
then
echo -e " Converting the output into a flashable zip"
rm -rf chriszuma_install
mkdir -p chriszuma_install
make -j4 modules_install INSTALL_MOD_PATH=chriszuma_install INSTALL_MOD_STRIP=1
mkdir -p cwm_flash_zip/system/lib/modules/pronto
find chriszuma_install/ -name '*.ko' -type f -exec cp '{}' cwm_flash_zip/system/lib/modules/ \;
mv cwm_flash_zip/system/lib/modules/wlan.ko cwm_flash_zip/system/lib/modules/pronto/pronto_wlan.ko
cp arch/arm/boot/zImage cwm_flash_zip/tools/
cp arch/arm/boot/dt.img cwm_flash_zip/tools/
rm -f /home/christian/chriszuma_kernel_surnia.zip
cd cwm_flash_zip
zip -r ../arch/arm/boot/chriszuma_kernel_surnia.zip ./
mv $Kernel_Dir/arch/arm/boot/chriszuma_kernel_surnia.zip /home/christian
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
else
echo "Compilation failed! Fix the errors!"
fi

