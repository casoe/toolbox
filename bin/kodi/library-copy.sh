#!/bin/bash

# library-copy.sh - process a file with a list of files and copy them to
# a destination folder

set -x

if [ $# != 1 ]; then
    echo "Command requires 1 argument: library file like 'fhem-library'"
fi

DIR="$(cut -d'-' -f1 <<<"$1")"
mkdir -p $DIR

for OUTPUT in $(cat $1)
do
  cp $OUTPUT $DIR/
done
