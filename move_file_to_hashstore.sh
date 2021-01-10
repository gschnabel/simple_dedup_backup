#!/bin/bash

if [ ! "$#" -eq 2 ]; then
    >&2 echo "ERROR: Expect two arguments --- file_store and source_path"
    exit 1
fi

file_store="$1"
source_path="$2"

source_dir=$(dirname "$source_path")
source_file=$(basename "$source_path")

# check if proper file hash store
verifile="$file_store/.fstore_info"
if [ ! -f "$verifile" ]; then
    >&2 echo "ERROR: Not a filestore [$file_store]"
    exit 1
fi

first_char=$(echo "$file_store" | cut -c1)
if [ ! "$first_char" = "/" ]; then
    >&2 echo "ERROR: Filestore path must be absolute"
    exit 1
fi

# check the source path
if [ ! -f "$source_path" ]; then
    >&2 echo "ERROR: File does not exist [$source_path]"
    exit 1
fi

if [ -L "$source_path" ]; then
    >&2 echo "ERROR: Symbolic links are not allowed"
    exit 1
fi

# calculate hash
hash=$(sha256sum "$source_path" | cut -d' ' -f1)
dirbin="$(echo $hash | cut -c1-2)/$(echo $hash | cut -c3-4)"
hashdir="$file_store/$dirbin"
hashfile="$hashdir/sha256sum---$hash"
metafile="$hashfile.info.txt"
mkdir -p "$hashdir"
if [ ! "$?" -eq 0 ]; then
    >&2 echo "ERROR: Could not create hashbin directory [$hashdir]"
    exit 1
fi


if [ -f "$hashfile" ]; then

    # if hashfile already exists, make sure it is identical
    hashfile_size=$(stat --printf="%s" "$hashfile")
    sourcefile_size=$(stat --printf="%s" "$source_path")
    if [ "$hashfile_size" -eq "$sourcefile_size" ]; then
        restoredir=$(mktemp -d -p "$source_dir" "${source_file}.restore_XXXXX")
        if [ ! "$?" -eq 0 ]; then
            >&2 echo "ERROR: Could no create temporary directory [$restoredir]"
            exit 1
        fi
        restorefile="$restoredir/$source_file"
        mv "$source_path" "$restorefile"
        if [ ! "$?" -eq 0 ]; then
            >&2 echo "ERROR: Could not remove the original file [$source_path]"
            exit 1
        fi

        ln "$hashfile" "$source_path" 
        if [ "$?" -eq 0 ]; then
            # clean up the tempdir
            rm -rf "$restoredir"
            # save meta information
            echo "$source_path" >> "$metafile" 
        else
            >&2 echo "ERROR: Could not create the link in the place where the original source file was [$source_file --> $hashfile]"
            mv "$restorefile" "$source_path"
            if [ "$?" -eq 0 ]; then
                rm -rf "$restoredir"
            fi
            exit 1
        fi
    else
        >&2 echo "FATAL ERROR: File in hashstore and current file have same hash"
        >&2 echo "FATAL ERROR: but different size, which should be impossible"
        >&2 echo "FATAL ERROR: [$hashfile vs $source_path]"
        exit 1
    fi
# hashfile does not exist
else
    ln "$source_path" "$hashfile"
    if [ ! "$?" -eq 0 ]; then
        >&2 echo "ERROR: Failed to create hashfile in hashstore"
    fi
    echo "$source_path" >> "$metafile" 
fi
