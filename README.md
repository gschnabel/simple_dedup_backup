### Simple backup with deduplication

A few simple scripts that assist in making backups
of directories on Unix-like systems with filesystems
that support hard links.

#### Usage:

```
sh make_backup.sh [source-dir] [dest-dir]
```
Creates a directory in `dest-dir` with the name
of `source-dir` suffixed by the current date and
time in human-readable form. All files of 
`source-dir` are copied into this new directory.

```
sh move_dir_to_hashstore.sh [hash-store] [dir]
```
Stores each regular file in `dir` in the directory
`hash-store` under a new name, which is the
sha256 hash of the file content.
Files in `dir` are then replaced by hard links
to the files in `hash-store`.
Please note that the directory `hash-store` must exist
and contain the file `.fstore_info`.
Also `dir` and `hash-store` must be on the same
partition in order to enable the use of 
hard links.
