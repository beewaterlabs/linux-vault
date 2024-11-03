#!/usr/bin/bash

# Check if the file exists

if [ ! -f "$1" ]; then

  echo "Error: File does not exist"

  exit 1

fi

# Sort the file alphabetically

sort "$1" > temp.txt

# Move the sorted file to the original file

mv temp.txt "$1"
