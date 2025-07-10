#!/bin/bash

# Simple Media Date Renamer
# Renames photo/video files using metadata timestamps
# Usage: ./simple_renamer.sh [directory]

# Exit on any error
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check exiftool
if ! command -v exiftool &> /dev/null; then
    echo -e "${RED}Error: exiftool not found. Install with: brew install exiftool${NC}"
    exit 1
fi

# Get directory (default to current)
DIR="${1:-.}"

# Check if directory exists
if [[ ! -d "$DIR" ]]; then
    echo -e "${RED}Error: Directory '$DIR' does not exist${NC}"
    exit 1
fi

echo -e "${GREEN}Processing directory: $DIR${NC}"

# Process each file
find "$DIR" -maxdepth 1 -type f | while read -r file; do
    filename=$(basename "$file")
    ext="${filename##*.}"
    ext_lc=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    
    # Check if supported
    case "$ext_lc" in
        jpg|jpeg|png|gif|bmp|tiff|tif|heic|heif|cr2|nef|arw|orf|mp4|mov|avi|mkv|wmv|flv|webm|3gp|m4v|mpg|mpeg)
            # Only skip files that match the new format: YYYY-MM-DD_HH-MM-SS-FFF.EXT
            if [[ "$filename" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]+ ]]; then
                echo -e "${BLUE}Skipping already renamed file: $filename${NC}"
                continue
            fi
            
            # Extract timestamp with full precision
            timestamp=$(exiftool -quiet -CreateDate "$file" 2>/dev/null | cut -d: -f2- | sed 's/^ *//')
            
            if [[ -z "$timestamp" ]]; then
                timestamp=$(exiftool -quiet -DateTimeOriginal "$file" 2>/dev/null | cut -d: -f2- | sed 's/^ *//')
            fi
            
            if [[ -n "$timestamp" ]]; then
                # Extract fractional seconds before cleaning
                fractional=$(echo "$timestamp" | grep -o '\.[0-9]*' | sed 's/\.//')
                if [[ -z "$fractional" ]]; then
                    fractional="000"
                fi
                
                # Clean timestamp: remove fractional seconds and timezone
                timestamp_clean=$(echo "$timestamp" | sed 's/\.[0-9]*//' | sed 's/[+-][0-9][0-9]:[0-9][0-9]//')
                
                # Parse timestamp components (force correct separators)
                year=$(echo "$timestamp_clean" | awk '{print substr($1,1,4)}')
                month=$(echo "$timestamp_clean" | awk '{print substr($1,6,2)}')
                day=$(echo "$timestamp_clean" | awk '{print substr($1,9,2)}')
                hour=$(echo "$timestamp_clean" | awk '{print substr($2,1,2)}')
                minute=$(echo "$timestamp_clean" | awk '{print substr($2,4,2)}')
                second=$(echo "$timestamp_clean" | awk '{print substr($2,7,2)}')
                
                # Format as YYYY-MM-DD_HH-MM-SS-FFF (no spaces)
                new_name="${year}-${month}-${day}_${hour}-${minute}-${second}-${fractional}.${ext}"
                
                # Handle duplicates
                counter=1
                original_name="$new_name"
                while [[ -f "$DIR/$new_name" ]]; do
                    new_name="${original_name%.*}_${counter}.${ext}"
                    ((counter++))
                done
                
                # Rename file
                if mv "$file" "$DIR/$new_name"; then
                    echo -e "${GREEN}Renamed: $filename → $new_name${NC}"
                else
                    echo -e "${RED}Failed to rename: $filename${NC}"
                fi
            else
                echo -e "${YELLOW}No timestamp found for: $filename${NC}"
            fi
            ;;
        *)
            echo -e "${YELLOW}Skipping unsupported file: $filename${NC}"
            ;;
    esac
done

echo -e "${GREEN}Done!${NC}" 
