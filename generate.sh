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

# modify "Modules" header to "Functions"
# FIXME: do this within config.ld
for F in $(find docs/ -type f -name "*.html"); do
	sed -i -e 's|<h2>Modules</h2>|<h2>Functions</h2>|' "$F";
done
