#!/usr/bin/env bash

source ${SCRIPTS_DIR}/download-and-extract.sh

version=3.4.0

downloadTarArchive \
  "openssl" \
  "https://github.com/openssl/openssl/releases/download/openssl-${version}/openssl-${version}.tar.gz"

openssl_configurations_path=${SOURCES_DIR_openssl}/Configurations
awk -i inplace '!/"shlib_variant => 34,"/' ${openssl_configurations_path}/15-android.conf || exit 1
awk -i inplace '1;/"android" =>/{ print "shlib_variant => 34,"; }' ${openssl_configurations_path}/15-android.conf || exit 1
