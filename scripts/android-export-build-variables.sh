#!/usr/bin/env bash

function max() {
  [[ $1 -ge $2 ]] && echo "$1" || echo "$2"
}

export DESIRED_ANDROID_API_LEVEL=34

if [ $ANDROID_ABI = "arm64-v8a" ] || [ $ANDROID_ABI = "x86_64" ]; then
  # For 64bit we use value not less than 21
  export ANDROID_PLATFORM=$(max ${DESIRED_ANDROID_API_LEVEL} 21)
else
  export ANDROID_PLATFORM=${DESIRED_ANDROID_API_LEVEL}
fi

export TOOLCHAIN_PATH=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${HOST_TAG}
export SYSROOT_PATH=${TOOLCHAIN_PATH}/sysroot

target_triple_machine_cc=
CPU_FAMILY=
export TARGET_TRIPLE_OS="android"

case $ANDROID_ABI in
armeabi-v7a)
  #cc       armv7a-linux-androideabi16-clang
  export TARGET_TRIPLE_MACHINE_ARCH=arm
  target_triple_machine_cc=armv7a
  export TARGET_TRIPLE_OS=androideabi
  ;;
arm64-v8a)
  #cc       aarch64-linux-android21-clang
  export TARGET_TRIPLE_MACHINE_ARCH=aarch64
  ;;
x86)
  #cc       i686-linux-android16-clang
  export TARGET_TRIPLE_MACHINE_ARCH=i686
  CPU_FAMILY=x86
  ;;
x86_64)
  #cc       x86_64-linux-android21-clang
  export TARGET_TRIPLE_MACHINE_ARCH=x86_64
  ;;
*)
  #cc       x86_64-linux-android21-clang
  echo "Unknown target architecture: ${ANDROID_ABI}"
  exit 1
  ;;
esac

# If the cc-specific variable isn't set, we fallback to binutils version
[ -z "${target_triple_machine_cc}" ] && target_triple_machine_cc=${TARGET_TRIPLE_MACHINE_ARCH}

[ -z "${CPU_FAMILY}" ] && CPU_FAMILY=${TARGET_TRIPLE_MACHINE_ARCH}
export CPU_FAMILY=${CPU_FAMILY}

# Common prefix for ld, as, etc.
export CROSS_PREFIX_WITH_PATH=${TOOLCHAIN_PATH}/bin/llvm-

# Exporting Binutils paths, if passing just CROSS_PREFIX_WITH_PATH is not enough
# The FAM_ prefix is used to eliminate passing those values implicitly to build systems
export FAM_ADDR2LINE=${CROSS_PREFIX_WITH_PATH}addr2line
export FAM_AR=${CROSS_PREFIX_WITH_PATH}ar
export FAM_AS=${CROSS_PREFIX_WITH_PATH}as
export FAM_NM=${CROSS_PREFIX_WITH_PATH}nm
export FAM_OBJCOPY=${CROSS_PREFIX_WITH_PATH}objcopy
export FAM_OBJDUMP=${CROSS_PREFIX_WITH_PATH}objdump
export FAM_RANLIB=${CROSS_PREFIX_WITH_PATH}ranlib
export FAM_READELF=${CROSS_PREFIX_WITH_PATH}readelf
export FAM_SIZE=${CROSS_PREFIX_WITH_PATH}size
export FAM_STRINGS=${CROSS_PREFIX_WITH_PATH}strings
export FAM_STRIP=${CROSS_PREFIX_WITH_PATH}strip

export TARGET=${target_triple_machine_cc}-linux-${TARGET_TRIPLE_OS}${ANDROID_PLATFORM}
# The name for compiler is slightly different, so it is defined separately.
export FAM_CC=${TOOLCHAIN_PATH}/bin/${TARGET}-clang
export FAM_CXX=${FAM_CC}++
export FAM_LD=${FAM_CC}

# Special variable for the yasm assembler
export FAM_YASM=${TOOLCHAIN_PATH}/bin/yasm
