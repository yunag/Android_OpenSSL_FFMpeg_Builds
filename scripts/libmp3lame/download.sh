#!/usr/bin/env bash

source ${SCRIPTS_DIR}/download-and-extract.sh

version=3.100

downloadTarArchive \
  "libmp3lame" \
  "http://downloads.videolan.org/pub/contrib/lame/lame-${version}.tar.gz"
