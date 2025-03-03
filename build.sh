#!/usr/bin/env bash

# The root of the project
export BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

helpFunction() {
  echo "Usage: $0 <target-os> [--target-arch=ARCH]"
  echo -e "\t<target-os>     Select target os [windows, linux, android]"
  echo -e "\t--target-arch   Select target architecture [arm64-v8a, armeabi-v7a, x86, x86_64]"
  exit 1
}

# Parse command-line options
for opt in "$@"; do
  case "$opt" in
  --target-arch=*)
    export ANDROID_ABI="${opt#*=}"
    ;;
  windows)
    export TARGET_OS=windows
    ;;
  android)
    export TARGET_OS=android
    ;;
  linux)
    export TARGET_OS=linux
    ;;
  *)
    helpFunction
    ;;
  esac
done

# Directory to use as a place to build/install FFmpeg and its dependencies
export BUILD_DIR=${BASE_DIR}/build
export SCRIPTS_DIR=${BASE_DIR}/scripts
export SOURCES_DIR=${BASE_DIR}/sources

if [[ ${TARGET_OS} == android ]]; then
  if [[ -z "${ANDROID_NDK_ROOT}" ]]; then
    echo "ANDROID_NDK_ROOT is not set"
    exit 1
  fi

  export INSTALL_DIR=${BUILD_DIR}/${TARGET_OS}/${ANDROID_ABI}

  # Exporting more necessary variabls
  source ${SCRIPTS_DIR}/android-export-host-variables.sh

  # Exporting variables for the current abi
  source ${SCRIPTS_DIR}/android-export-build-variables.sh
else
  export INSTALL_DIR=${BUILD_DIR}/${TARGET_OS}
fi

rm -rf ${INSTALL_DIR}

# Treating FFmpeg as just a module to build after its dependencies
components_to_build=("libmp3lame")
if [[ ${TARGET_OS} == android ]]; then
  # Don't waste time building openssl for Desktop
  components_to_build+=("openssl")
fi
components_to_build+=("ffmpeg")

for component in ${components_to_build[@]}; do
  echo "Getting source code of the component: ${component}"
  source_dir_for_component=${SOURCES_DIR}/${component}

  mkdir -p ${source_dir_for_component}

  pushd ${source_dir_for_component}
  # Executing the component-specific script for downloading the source code
  source ${SCRIPTS_DIR}/${component}/download.sh
  popd
done

for component in ${components_to_build[@]}; do
  echo "Building the component: ${component}"
  component_sources_dir_variable=SOURCES_DIR_${component}

  # Going to the actual source code directory of the current component
  pushd ${!component_sources_dir_variable}
  # and executing the component-specific build script
  source ${SCRIPTS_DIR}/${component}/build.sh || exit 1
  popd
done
