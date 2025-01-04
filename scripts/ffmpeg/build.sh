#!/usr/bin/env bash

export FFMPEG_INSTALL_DIR=${INSTALL_DIR}/ffmpeg

# Referencing dependencies without pkgconfig
dep_cflags="-I${INSTALL_DIR}/include"
dep_ldflags="-L${INSTALL_DIR}/lib"

common_cflags="-O2 ${dep_cflags}"
common_ldflags="${dep_ldflags}"

# Android 15 with 16 kb page size support
# https://developer.android.com/guide/practices/page-sizes#compile-r27
android_extra_cflags="-I${OPENSSL_INSTALL_DIR}/include -fPIC"
android_extra_ldflags="-L${OPENSSL_INSTALL_DIR}/lib -lssl34 -lcrypto34 -Wl,-z,max-page-size=16384"

common_options=(
--prefix="${FFMPEG_INSTALL_DIR}"
--disable-everything
--disable-autodetect
--disable-programs
--disable-doc
--disable-static
--enable-version3
--enable-shared
--enable-network
--enable-openssl
--enable-libmp3lame
--enable-encoder=libmp3lame
--enable-parser=mpegaudio
--enable-decoder=mp3*,aac*,ac3*,flac,opus,vorbis
--enable-demuxer=pcm*,wav,mp3,aac,ac3,ogg,flac
--enable-muxer=wav,mp3
--enable-protocol=file,udp,tls,tcp,http*,icecast
--enable-filter=aresample
--enable-neon
)

android_options=(
"${common_options[@]}"
--enable-cross-compile
--target-os=android
--arch="${TARGET_TRIPLE_MACHINE_ARCH}"
--sysroot="${SYSROOT_PATH}"
--cc="${FAM_CC}"
--cxx="${FAM_CXX}"
--ld="${FAM_LD}"
--ar="${FAM_AR}"
--as="${FAM_CC}"
--nm="${FAM_NM}"
--ranlib="${FAM_RANLIB}"
--strip="${FAM_STRIP}"
--extra-cflags="${common_cflags} ${android_extra_cflags}"
--extra-ldflags="${common_ldflags} ${android_extra_ldflags}"
)

case "$ANDROID_ABI" in
  x86|x86_64)
    # Disabling assembler optimizations, because they have text relocations
    android_options+=(
      --disable-asm
    )
    ;;
esac

windows_options=(
"${common_options[@]}"
--extra-cflags="${common_cflags}"
--extra-ldflags="${common_ldflags}"
)

configure_android() {
  (set -x; ./configure "${android_options[@]}")
}

configure_windows() {
  (set -x; ./configure "${windows_options[@]}")
}

case $TARGET_OS in
  win)
    configure_windows || exit 1
    ;;
  android)
    configure_android || exit 1
    ;;
esac

make clean
make -j
make install
