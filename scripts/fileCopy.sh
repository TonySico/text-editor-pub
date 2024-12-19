#!/bin/bash

# Check if a directory is provided as an argument, otherwise use the current directory
source_directory="${1:-.}"
target_directory="${2:-$source_directory}"  # Default to source_directory if no target is specified

# Verify that the source directory is a valid directory
if [ ! -d "$source_directory" ]; then
  echo "Error: '$source_directory' is not a valid source directory."
  exit 1
fi

# Verify that the target directory is a valid directory
if [ ! -d "$target_directory" ]; then
  echo "Error: '$target_directory' is not a valid target directory."
  exit 1
fi

# Create a folder for each extension (fully capitalized) and copy the corresponding files into it
find "$source_directory" -type f | \
  sed -E 's/.*\.(.*)$/\1/' | \
  sort | \
  uniq | \
  while read ext; do
    # Skip empty extensions (in case there are files without extensions)
    if [ -n "$ext" ]; then
      # Capitalize the entire extension
      capitalized_ext="$(echo "$ext" | tr 'a-z' 'A-Z')"
      target_dir="$target_directory/${capitalized_ext}nano"
      mkdir -p "$target_dir"  # Create the directory if it doesn't exist
      find "$source_directory" -type f -name "*.$ext" -exec cp {} "$target_dir" \;  # Copy files
      echo "Copied .$ext files to $target_dir"
    fi
  done

