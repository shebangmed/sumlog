#! /bin/bash

# Settings
hashlog="hashlog.txt" # Hashes will be appended to this file (absolute path)
hashtype="256" # +info: "man shasum"

datetime=$(date +"%Y-%m-%d %T") # System date and time, for output
# Note: In the future, date and time from NTP server may be added

# Needed for getting file type
file_ls=$(ls -l "$1") # Dir starts with "d", files with "-"
filetype=${file_ls:0:1} # Gets 1st character in $file_ls via expansion

# If input is a directory, a file list is needed
# File lists are generated using Tree (must be installed)
# Then, a while read loop reads file list line by line and pipes output to hashfile function
function list () {
    tree -if --nolinks --noreport "$1" > "$temp_tree"
    # LAST=$(tail -n2 "$temp_tree")
    # cat "$LAST"
    # sed -i "/$LAST/d" "$temp_tree"
    # ls -dR "$1" > "$temp_tree"
    # temp_tree=$(ls -dR "$1")
    while read -r file ; do
        hashfile
    done <"$temp_tree"
    
    rm "$temp_tree"
}

# This function computes hashes as defined in preamble and appends them into a textfile
function hashfile () {
    sha=$(shasum -a "$hashtype" "$file") # Getting hash
    echo ["$datetime" - SHA"$hashtype"] "$sha" >> $hashlog # turn off for debugging
    # echo ["$datetime" - SHA"$hashtype"] "$sha" # turn on for debugging
}

# BASH SCRIPT
# A simple if/else statement differenctiates directories and files using $filetype variable as explained before
if [ "$filetype" == "-" ]; then
    echo "IS: FILE"
    file=$1
    hashfile # Hash for the file is computed directly
else
    echo "IS: DIRECTORY"
    temp_tree=$(mktemp) # Temporary file for the file list
    list "$@" # Many hashes are computed sequentially
fi