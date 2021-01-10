#!/bin/sh

file_store=$1
dirpath=$2

# verify file store
verifile="$file_store/.fstore_info"
if [ ! -f "$verifile" ]; then
    >&2 echo "ERROR: Not a filestore [$file_store]"
    exit 1
fi

first_char="$(echo $file_store | cut -c1)"
if [ ! "$first_char" = "/" ]; then
    >&2 echo "ERROR: Filestore path must be absolute"
    exit 1
fi

# verify the directory
if [ ! -d "$dirpath" ]; then
    >&2 echo "ERROR: Directory not found. [$dirpath]"
    exit 1
fi

# move the files into hashstore 
find "$dirpath" -type f -print0 | xargs -0 -n1 sh move_file_to_hashstore.sh "$file_store"
