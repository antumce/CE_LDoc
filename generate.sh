#!/bin/sh

# Shell script to clean & re-generate HTML docs dir.
#
# License: CC0

DIR_ROOT="$(dirname $0)"
DIR_DOCS="${DIR_ROOT}/docs"

if [ ! -d "${DIR_DOCS}" ]; then
	mkdir -p "${DIR_DOCS}"
else
	# clean up old docs
	find "${DIR_DOCS}" -type f -delete
	find "${DIR_DOCS}" -mindepth 1 -type d -empty -delete
fi

# generate new docs
ldoc "${DIR_ROOT}"
