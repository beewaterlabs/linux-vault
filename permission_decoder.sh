# Permission_Decoder_Shell_Script

This bash script provides the three methods for decoding file permissions:

# Add execute permissions to the script with chmod +x permission_decoder.sh for easier usage.

1. From a file path: Gets the actual permissions of an existing file
2. From a permission string: Converts strings like 'rwxr-xr--' to their octal values
3. From ls -l output: Parses the permission section from ls -l command output

The script is designed to work on both Linux and macOS, as they use different syntax for the stat command.
Usage Examples:

1. Check permissions of an existing file:

bashCopybash permission_decoder.sh -f /path/to/your/file

2. Convert a permission string:

bashCopybash permission_decoder.sh -p rwxr-xr--

3. Parse ls -l output:

bashCopybash permission_decoder.sh -l "-rwxr-xr-- 1 user group 4096 Jan 1 12:34 somefile"
How it works:

1. The script calculates chmod values by checking each position in the permission string and adding the appropriate value (4 for read, 2 for write, 1 for execute) for each user category (owner, group, others).

2. When checking an actual file, it uses the stat command with OS-specific flags to get both the symbolic and octal representation of the permissions.

3. For ls output, it extracts the permission string (skipping the first character which represents the file type) and converts it to the corresponding chmod value.

# permission_decoder.sh:

#!/bin/bash

# Function to convert permission string to chmod octal value
decode_permission_to_chmod() {
  local perm="$1"
  
  # Check if permission string is valid
  if [[ ${#perm} -ne 9 ]]; then
    echo "Error: Permission string must be exactly 9 characters long"
    exit 1
  fi
  
  # Calculate octal value
  local owner=0
  local group=0
  local others=0
  
  # Owner permissions
  [[ ${perm:0:1} == "r" ]] && ((owner+=4))
  [[ ${perm:1:1} == "w" ]] && ((owner+=2))
  [[ ${perm:2:1} == "x" ]] && ((owner+=1))
  
  # Group permissions
  [[ ${perm:3:1} == "r" ]] && ((group+=4))
  [[ ${perm:4:1} == "w" ]] && ((group+=2))
  [[ ${perm:5:1} == "x" ]] && ((group+=1))
  
  # Others permissions
  [[ ${perm:6:1} == "r" ]] && ((others+=4))
  [[ ${perm:7:1} == "w" ]] && ((others+=2))
  [[ ${perm:8:1} == "x" ]] && ((others+=1))
  
  echo "${owner}${group}${others}"
}

# Function to get permission from file
decode_file_permission() {
  local file="$1"
  
  # Check if file exists
  if [[ ! -e "$file" ]]; then
    echo "Error: File '$file' not found"
    exit 1
  fi
  
  # Get permissions with stat command
  local stat_format
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    stat_format=$(stat -f "%Lp %A" "$file")
    local octal_value=$(echo "$stat_format" | cut -d' ' -f1)
    local perm_string=$(echo "$stat_format" | cut -d' ' -f2 | cut -c2-10)
  else
    # Linux
    stat_format=$(stat -c "%a %A" "$file")
    local octal_value=$(echo "$stat_format" | cut -d' ' -f1)
    local perm_string=$(echo "$stat_format" | cut -d' ' -f2 | cut -c2-10)
  fi
  
  echo "File: $file"
  echo "Permissions: $perm_string"
  echo "Chmod value: $octal_value"
}

# Function to decode ls -l output
decode_ls_output() {
  local ls_output="$1"
  
  # Extract the permission string (skip first character which is file type)
  local perm_with_type=$(echo "$ls_output" | awk '{print $1}')
  local perm_string=${perm_with_type:1:9}
  
  if [[ ${#perm_string} -ne 9 ]]; then
    echo "Error: Invalid ls -l output format"
    exit 1
  fi
  
  local chmod_value=$(decode_permission_to_chmod "$perm_string")
  
  echo "Permissions: $perm_string"
  echo "Chmod value: $chmod_value"
}

# Main script
if [[ $# -lt 2 ]]; then
  echo "Usage:"
  echo "  $0 -f FILE              Decode permissions of FILE"
  echo "  $0 -p PERMISSION_STRING Decode PERMISSION_STRING (e.g., rwxr-xr--)"
  echo "  $0 -l \"LS_OUTPUT\"       Decode permissions from ls -l output"
  exit 1
fi

option="$1"
value="$2"

case "$option" in
  -f|--file)
    decode_file_permission "$value"
    ;;
  -p|--permission)
    if [[ ${#value} -ne 9 ]]; then
      echo "Error: Permission string must be exactly 9 characters long"
      exit 1
    fi
    chmod_value=$(decode_permission_to_chmod "$value")
    echo "Permissions: $value"
    echo "Chmod value: $chmod_value"
    ;;
  -l|--ls-output)
    decode_ls_output "$value"
    ;;
  *)
    echo "Error: Unknown option $option"
    echo "Usage:"
    echo "  $0 -f FILE              Decode permissions of FILE"
    echo "  $0 -p PERMISSION_STRING Decode PERMISSION_STRING (e.g., rwxr-xr--)"
    echo "  $0 -l \"LS_OUTPUT\"       Decode permissions from ls -l output"
    exit 1
    ;;
esac
