#!/usr/bin/env bash

# Defining a toolchain directory's name according to the current OS.
# Assume that proper version of NDK is installed
# and is referenced by ANDROID_NDK_ROOT environment variable
case "$OSTYPE" in
  darwin*)  HOST_TAG="darwin-x86_64" ;;
  linux*)   HOST_TAG="linux-x86_64" ;;
  msys)
    case "$(uname -m)" in
      x86_64) HOST_TAG="windows-x86_64" ;;
      i686)   HOST_TAG="windows" ;;
    esac
  ;;
esac

# The variable is used as a path segment of the toolchain path
export HOST_TAG=$HOST_TAG
