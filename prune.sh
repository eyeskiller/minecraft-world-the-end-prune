#!/bin/bash

#Specify yout world the end DIM1 directory
cd /path/to/world_the_end/DIM1/region/

# Exit if the directory isn't found.
if (($?>0)); then
    echo "Can't find work dir... exiting"
    exit
fi

for i in *; do
    # Specify path to filelist.txt
    if ! grep -qxFe "$i" /path/to/filelist.txt; then
        echo "Deleting: $i"
        rm "$i"
    fi
done
