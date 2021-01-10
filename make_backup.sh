#!/bin/sh

source_path=$1
dest_path=$2

source_dir=$(basename $source_path)
datestr=$(date +"%Y-%m-%d---%H-%M-%S---%N")
dest_dir="$source_dir---$datestr"
dest_path2="$dest_path/$dest_dir"

# checks of input
if [ ! -d "$source_path" ]; then
    >&2 echo "Source directory does not exist. [$source_path]"
fi

if [ -d "$dest_path2" ]; then
    >&2 echo "Destination directory exists, which must not happen. [$dest_path2]"
    exit 1
fi

# transfer the files
mkdir -p $dest_path2
rsync -rl $source_path/ $dest_path2
