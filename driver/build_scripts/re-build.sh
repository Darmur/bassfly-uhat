#!/bin/bash

CPU=8
KERNEL_VERSION="5.4.83"

case $KERNEL_VERSION in
    "5.10.3")
      KERNEL_COMMIT="da59cb1161dc7c75727ec5c7636f632c52170961"
      PATCH="bassfly-5.10.x.patch"
      ;;
    "5.4.83")
      KERNEL_COMMIT="b7c8ef64ea24435519f05c38a2238658908c038e"
      PATCH="bassfly-5.4.x.patch"
      ;;
    "5.4.81")
      KERNEL_COMMIT="453e49bdd87325369b462b40e809d5f3187df21d"
      PATCH="bassfly-5.4.x.patch"
      ;;
    "5.4.79")
      KERNEL_COMMIT="0642816ed05d31fb37fc8fbbba9e1774b475113f"
      PATCH="bassfly-5.4.x.patch"
      ;;
    "5.4.72")
      KERNEL_COMMIT="b3b238cf1e64d0cc272732e77ae6002c75184495"
      PATCH="bassfly-5.4.x.patch"
      ;;
    "5.4.59")
      KERNEL_COMMIT="caf7070cd6cece7e810e6f2661fc65899c58e297"
      PATCH="bassfly-5.4.x.patch"
      ;;
    "5.4.51")
      KERNEL_COMMIT="8382ece2b30be0beb87cac7f3b36824f194d01e9"
      PATCH="bassfly-5.4.x.patch"
      ;;
    "4.19.118")
      KERNEL_COMMIT="e1050e94821a70b2e4c72b318d6c6c968552e9a2"
      PATCH="bassfly-4.19.x.patch"
      ;;
    "4.14.92")
      KERNEL_COMMIT="6aec73ed5547e09bea3e20aa2803343872c254b6"
      PATCH="bassfly-4.14.x.patch"
      ;;
esac

echo "!!!  Build modules for kernel ${KERNEL_VERSION}  !!!"

echo "!!!  Build RPi0 kernel and modules  !!!"
cd linux-${KERNEL_VERSION}+/
KERNEL=kernel
make -j${CPU} ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- bcmrpi_defconfig
make -j${CPU} ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage modules dtbs
cd ..
echo "!!!  RPi0 build done  !!!"
echo "-------------------------"

echo "!!!  Build RPi3 kernel and modules  !!!"
cd linux-${KERNEL_VERSION}-v7+/
KERNEL=kernel7
make -j${CPU} ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- bcm2709_defconfig
make -j${CPU} ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage modules dtbs
cd ..
echo "!!!  RPi3 build done  !!!"
echo "-------------------------"

echo "!!!  Build RPi4 kernel and modules  !!!"
cd linux-${KERNEL_VERSION}-v7l+/
KERNEL=kernel7l
make -j${CPU} ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- bcm2711_defconfig
make -j${CPU} ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage modules dtbs
cd ..
echo "!!!  RPi4 build done  !!!"
echo "-------------------------"

echo "!!!  Creating archive  !!!"
rm -rf modules-rpi-${KERNEL_VERSION}-bassfly/
mkdir -p modules-rpi-${KERNEL_VERSION}-bassfly/boot/overlays
mkdir -p modules-rpi-${KERNEL_VERSION}-bassfly/lib/modules/${KERNEL_VERSION}+/kernel/sound/soc/codecs/
mkdir -p modules-rpi-${KERNEL_VERSION}-bassfly/lib/modules/${KERNEL_VERSION}-v7+/kernel/sound/soc/codecs/
mkdir -p modules-rpi-${KERNEL_VERSION}-bassfly/lib/modules/${KERNEL_VERSION}-v7l+/kernel/sound/soc/codecs/
cp linux-${KERNEL_VERSION}+/arch/arm/boot/dts/overlays/bassfly.dtbo modules-rpi-${KERNEL_VERSION}-bassfly/boot/overlays
cp linux-${KERNEL_VERSION}+/sound/soc/codecs/snd-soc-tfa9879.ko modules-rpi-${KERNEL_VERSION}-bassfly//lib/modules/${KERNEL_VERSION}+/kernel/sound/soc/codecs/
cp linux-${KERNEL_VERSION}-v7+/sound/soc/codecs/snd-soc-tfa9879.ko modules-rpi-${KERNEL_VERSION}-bassfly//lib/modules/${KERNEL_VERSION}-v7+/kernel/sound/soc/codecs/
cp linux-${KERNEL_VERSION}-v7l+/sound/soc/codecs/snd-soc-tfa9879.ko modules-rpi-${KERNEL_VERSION}-bassfly//lib/modules/${KERNEL_VERSION}-v7l+/kernel/sound/soc/codecs/
tar -czvf modules-rpi-${KERNEL_VERSION}-bassfly.tar.gz modules-rpi-${KERNEL_VERSION}-bassfly/ --owner=0 --group=0
md5sum modules-rpi-${KERNEL_VERSION}-bassfly.tar.gz > modules-rpi-${KERNEL_VERSION}-bassfly.md5sum.txt
sha1sum modules-rpi-${KERNEL_VERSION}-bassfly.tar.gz > modules-rpi-${KERNEL_VERSION}-bassfly.sha1sum.txt

echo "!!!  Done  !!!"
