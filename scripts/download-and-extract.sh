#!/usr/bin/env bash

# Function that downloads an archive with the source code by the given url,
# extracts its files and exports a variable SOURCES_DIR_${library_name}
function downloadTarArchive() {
  # The full name of the library
  library_name=$1
  # The url of the source code archive
  download_url=$2
  # Optional. If 'true' then the function creates an extra directory for archive extraction.
  need_extra_dIRECTORY=$3

  archive_name=${download_url##*/}
  # File name without extension
  library_sources="${archive_name%.tar.*}"

  echo "Ensuring sources of ${library_name} in ${library_sources}"

  if [[ ! -d "$library_sources" ]]; then
    curl -LO ${download_url}

    extraction_dir="."
    if [ "$need_extra_dIRECTORY" = true ]; then
      extraction_dir=${library_sources}
      mkdir ${extraction_dir}
    fi

    tar xf ${archive_name} -C ${extraction_dir}
    rm ${archive_name}
  fi

  export SOURCES_DIR_${library_name}=$(pwd)/${library_sources}
}
