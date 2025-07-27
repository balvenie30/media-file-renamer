#!/bin/bash

# Simple script that renames media files
# It renames photo and video files that have EXIF metadata (Exchangeable image file format)
# (If you want to know more about EXIF metadata, see https://www.cipa.jp/e/std/std-sec.html)
# Usage: ./rename.sh [path to a file or directory]
# e.g. ./rename.sh /home/user1/photos/2024-01-01_12-00-00-0000.jpg
# e.g. ./rename.sh /home/user2/photos/

# Exit on any error
set -e

# Colors
COLOR_PROCESS='\033[0;36m'  # Cyan
COLOR_SUCCESS='\033[0;32m'  # Green
COLOR_ERROR='\033[0;31m'    # Red
COLOR_WARNING='\033[1;33m'  # Yellow
COLOR_ORIGINAL='\033[0;35m' # Magenta
COLOR_RESET='\033[0m'				# Resets color

# Check exiftool
if ! command exiftool -ver &> /dev/null; then
	echo -e "${COLOR_ERROR}Error: exiftool not found. Install with: brew install exiftool${COLOR_RESET}"
	exit 1
fi

# Parse arguments
path=$1

# Check if the path exists and is a file
if [[ -f "$path" ]]; then
  filename=$(basename "$path")

  # Extract date, time, subseconds and extension: exiftool -d "%Y%m%d_%H%M%S" -DateTimeOriginal -SubSecTimeOriginal -FileTypeExtension -s3 de.jpg
  # Store the output in variables
  datetime=$(exiftool -d "%Y%m%d_%H%M%S" -DateTimeOriginal -s3 "$path")
  subsec=$(exiftool -SubSecTimeOriginal -s3 "$path")
  extension=$(exiftool -FileTypeExtension -s3 "$path")

  # Check if datetime was extracted successfully
  if [[ -z "$datetime" ]]; then
    echo -e "${COLOR_ERROR}Error: This file doesn't have DateTimeOriginal value${COLOR_RESET}"
    exit 1
  fi

  # Assign 0 to subsec if it's empty
  if [[ -z "$subsec" ]]; then
    subsec="0"
  fi

  # Format the new filename
  new_filename="${datetime}_${subsec}.${extension}"
	echo -e "${COLOR_ORIGINAL}Original name: $filename${COLOR_RESET}"
  echo -e "${COLOR_PROCESS}New name: $new_filename${COLOR_RESET}"

  # Ask the user if they want to rename the file
  read -p "Rename file? (y/n): " -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    mv "$path" "$(dirname "$path")/$new_filename"
    echo -e "${COLOR_SUCCESS}File renamed successfully!${COLOR_RESET}"
  else
    echo -e "${COLOR_ERROR}Rename cancelled.${COLOR_RESET}"
  fi

# if the path is a directory, process the files in the directory
elif [[ -d "$path" ]]; then
	# get the list of files in the directory
	files=($(find "$path" -type f))
	echo -e "Number of files to process: ${#files[@]}"

	echo -e "Files:"
	printf '  %s\n' "${files[@]}"
	echo "----------------------------------------"

	# ask the user if they want to rename the files
	while true; do
		echo -e "${COLOR_WARNING}Press Ctrl+C to cancel at any time${COLOR_RESET}"
		read -p "Rename files? (y/n): " -r
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			# if y, rename the files
			echo "Starting file processing..."
			break
		elif [[ $REPLY =~ ^[Nn]$ ]]; then
			# if n, exit
			echo -e "${COLOR_WARNING}Operation cancelled by user.${COLOR_RESET}"
			exit 0
		else
			echo -e "${COLOR_ERROR}Invalid input. Please enter 'y' or 'n'.${COLOR_RESET}"
		fi
	done

	# count renamed files
	renamed_files=0
	# count unchanged files
	unchanged_files=0
	# count files with error
	files_with_error=0

	# iterate on the list
	for file in "${files[@]}"; do
		# print the file name to tell the user which file the script is working on
		# echo -e "${COLOR_WARNING}Processing file: $file${COLOR_RESET}"
		echo -e "${COLOR_WARNING}Processing file:${COLOR_RESET} $file"

		# get the value of `Date/Time Original` and `Sub Sec Time Original`
		datetime=$(exiftool -d "%Y%m%d_%H%M%S" -DateTimeOriginal -s3 "$file" 2>/dev/null || echo "")
		subsec=$(exiftool -SubSecTimeOriginal -s3 "$file" 2>/dev/null || echo "")
		extension=$(exiftool -FileTypeExtension -s3 "$file" 2>/dev/null || echo "")

		# if can't get the values, skip. (print that we're skipping)
		if [[ -z "$datetime" ]]; then
			echo -e "${COLOR_ERROR}Error:${COLOR_RESET} This file doesn't have DateTimeOriginal value"
			# count files with error
			((files_with_error++))
			continue
		fi
		# count renamed files
		((renamed_files++))
		# otherwise, rename the file
		new_filename="${datetime}_${subsec}.${extension}"
		filename=$(basename "$file")
		# if filename and new_filename are the same, skip and echo that we're skipping
		if [[ "$filename" == "$new_filename" ]]; then
			echo -e "${COLOR_WARNING}Skipping file: $filename (already has correct name)${COLOR_RESET}"
			((unchanged_files++))
			continue
		fi

		echo -e "${COLOR_ORIGINAL}Original name:${COLOR_RESET} $filename"
		mv "$file" "$(dirname "$file")/$new_filename"
		echo -e "${COLOR_PROCESS}New name:${COLOR_RESET}      $new_filename"
	done

	# show summary
	echo "----------------------------------------"
	echo -e "✅  Renamed: ${COLOR_SUCCESS}$renamed_files${COLOR_RESET}"
	echo -e "⚠️   Skipped: ${COLOR_WARNING}$unchanged_files${COLOR_RESET}"
	echo -e "❌  Errors:  ${COLOR_ERROR}$files_with_error${COLOR_RESET}"
	echo "----------------------------------------"
		
else
	echo -e "${COLOR_ERROR}It doesn't exist or is neither file nor directory${COLOR_RESET}"
fi
