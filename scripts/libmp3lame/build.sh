#!/usr/bin/env bash

cflags=
if [ "$ANDROID_ABI" = "x86" ] ; then
# mp3lame's configure script sets -mtune=native for i686,
# which leads to compilation errors on Mac with arm processors,
# because 'native' is recognized as apple-m1 processor.
# Passing an empty mtune resets the value to default
    cflags="-mtune="
fi

common_options=(
--prefix="${INSTALL_DIR}"
--disable-shared
--disable-fast-install
--disable-analyzer-hooks
--disable-gtktest
--disable-frontend
--enable-static
)

android_options=(
"${common_options[@]}"
--host="${TARGET}"
--with-pic
--with-sysroot="${SYSROOT_PATH}"
CFLAGS="${cflags}"
CC="${FAM_CC}"
AR="${FAM_AR}"
RANLIB="${FAM_RANLIB}"
)

configure_android() {
  (set -x; ./configure "${android_options[@]}") || cat ${SOURCES_DIR_libmp3lame}/config.log
}

configure_windows() {
  (set -x; ./configure "${common_options[@]}")
}

case $TARGET_OS in
  win)
    configure_windows
    ;;
  android)
    configure_android
    ;;
esac

make clean
make -j
make install
