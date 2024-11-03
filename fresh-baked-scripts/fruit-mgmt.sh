#!/bin/bash

# Here's a Bash script that will alphabetize a list of fruits passed as an argument and display an error message if no argument is provided:

# Check if an argument is provided
if [ -z "$1" ]; then
  echo "error (needs argument)"
  exit 1
fi

# Alphabetize the list of fruits passed as an argument
sorted_fruits=$(echo "$1" | tr ',' '\n' | sort | tr '\n' ',' | sed 's/,$//')

# Output the sorted list of fruits
echo "$sorted_fruits"

