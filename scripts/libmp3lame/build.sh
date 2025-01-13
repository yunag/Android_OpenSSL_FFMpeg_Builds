#!/usr/bin/env bash

cflags=
if [ "$ANDROID_ABI" = "x86" ]; then
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

linux_options=(
  "${common_options[@]}"
  --with-pic
)

configure_android() {
  (
    set -x
    ./configure "${android_options[@]}"
  )
}

configure_windows() {
  (
    set -x
    ./configure "${common_options[@]}"
  )
}

configure_linux() {
  (
    set -x
    ./configure "${linux_options[@]}"
  )
}

case "${TARGET_OS}" in
windows)
  configure_windows || exit 1
  ;;
android)
  configure_android || exit 1
  ;;
linux)
  configure_linux || exit 1
  ;;
esac

make clean
make -j
make install
