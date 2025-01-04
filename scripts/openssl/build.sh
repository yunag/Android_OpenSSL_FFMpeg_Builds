PATH=${TOOLCHAIN_PATH}/bin:$PATH

export OPENSSL_INSTALL_DIR=${INSTALL_DIR}/openssl

make clean

# Map ANDROID_ABI to OpenSSL android target
openssl_android_abi=
case $ANDROID_ABI in
  armeabi-v7a)
    openssl_android_abi="android-arm"
    ;;
  arm64-v8a)
    openssl_android_abi="android-arm64"
    ;;
  x86)
    openssl_android_abi="android-x86"
    ;;
  x86_64)
    openssl_android_abi="android-x86_64"
    ;;
esac

./Configure ${openssl_android_abi} \
  -D__ANDROID_API__=${ANDROID_PLATFORM} \
  --prefix=${OPENSSL_INSTALL_DIR}

make -j build_libs
make install_sw
