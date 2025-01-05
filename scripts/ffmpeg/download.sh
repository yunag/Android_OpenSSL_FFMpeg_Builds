#!/usr/bin/env bash

source ${SCRIPTS_DIR}/download-and-extract.sh

git_directory=ffmpeg-git
ffmpeg_sources=$(pwd)/${git_directory}

if [[ ! -d "${ffmpeg_sources}" ]]; then
  git clone https://github.com/FFmpeg/FFmpeg ${git_directory}
fi

pushd ${git_directory}

git reset --hard

# NOTE: I intentionally checkout to master branch since it plays better with my application
#
# For example: avformat_open_input is faster to probe certain mp3 streams
git checkout master
git pull origin master

# Additional logging to keep track of an exact commit to build
git rev-parse HEAD

popd

export SOURCES_DIR_ffmpeg=${ffmpeg_sources}
