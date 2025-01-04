#!/usr/bin/env bash

# The root of the project
export BASE_DIR="$( cd "$( dirname "$0" )" && pwd )"

# Directory to use as a place to build/install FFmpeg and its dependencies
build_dir=${BASE_DIR}/build

export SCRIPTS_DIR=${BASE_DIR}/scripts
export SOURCES_DIR=${BASE_DIR}/sources
export INSTALL_DIR=${build_dir}/windows
export TARGET_OS=win

rm -rf ${INSTALL_DIR}

components_to_build=( "libmp3lame" "ffmpeg" )

for component in ${components_to_build[@]}
do
  echo "Getting source code of the component: ${component}"
  source_dir_for_component=${SOURCES_DIR}/${component}

  mkdir -p ${source_dir_for_component}

  pushd ${source_dir_for_component}
  source ${SCRIPTS_DIR}/${component}/download.sh
  popd
done

for component in ${components_to_build[@]}
do
  echo "Building the component: ${component}"
  component_sources_dir_variable=SOURCES_DIR_${component}

  pushd ${!component_sources_dir_variable}
  source ${SCRIPTS_DIR}/${component}/build.sh || exit 1
  popd
done
