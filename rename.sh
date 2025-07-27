#!/bin/bash

# Media File Renamer
# =================
# This script renames photo and video files based on their EXIF metadata
# (Exchangeable Image File Format). It extracts the DateTimeOriginal and
# SubSecTimeOriginal values to create standardized filenames.
#
# For more information about EXIF metadata, see:
# https://www.cipa.jp/e/std/std-sec.html
#
# Usage: ./rename.sh [path to a file or directory]
# Examples:
#   ./rename.sh /home/user1/photos/2024-01-01_12-00-00-0000.jpg
#   ./rename.sh /home/user2/photos/

# Exit on any error
set -e

# =============================================================================
# CONFIGURATION
# =============================================================================

# Color definitions for output formatting (improved readability)
readonly COLOR_PROCESS='\033[1;34m'   # Bold Blue
readonly COLOR_SUCCESS='\033[1;32m'   # Bold Green
readonly COLOR_ERROR='\033[1;31m'     # Bold Red
readonly COLOR_WARNING='\033[1;33m'   # Bold Yellow
readonly COLOR_ORIGINAL='\033[1;36m'  # Bold Cyan
readonly COLOR_INFO='\033[0;37m'      # Light Gray for general info
readonly COLOR_RESET='\033[0m'        # Reset color

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Print colored output with improved formatting
print_info() {
    echo -e "${COLOR_INFO}$1${COLOR_RESET}"
}

print_success() {
    echo -e "${COLOR_SUCCESS}$1${COLOR_RESET}"
}

print_error() {
    echo -e "${COLOR_ERROR}Error: $1${COLOR_RESET}"
}

print_warning() {
    echo -e "${COLOR_WARNING}$1${COLOR_RESET}"
}

print_original() {
    echo -e "${COLOR_ORIGINAL}$1${COLOR_RESET}"
}

print_process() {
    echo -e "${COLOR_PROCESS}$1${COLOR_RESET}"
}

# Check if exiftool is installed
check_exiftool() {
    if ! command exiftool -ver &> /dev/null; then
        print_error "exiftool not found. Install with: brew install exiftool"
        exit 1
    fi
}

# Extract EXIF metadata from a file
extract_exif_data() {
    local file="$1"
    
    local datetime=$(exiftool -d "%Y%m%d_%H%M%S" -DateTimeOriginal -s3 "$file" 2>/dev/null || echo "")
    local subsec=$(exiftool -SubSecTimeOriginal -s3 "$file" 2>/dev/null || echo "")
    local extension=$(exiftool -FileTypeExtension -s3 "$file" 2>/dev/null || echo "")
    
    # Set default value for subsec if empty
    if [[ -z "$subsec" ]]; then
        subsec="0"
    fi
    
    echo "$datetime|$subsec|$extension"
}

# Generate new filename from EXIF data
generate_new_filename() {
    local datetime="$1"
    local subsec="$2"
    local extension="$3"
    
    echo "${datetime}_${subsec}.${extension}"
}

# Ask user for confirmation
ask_confirmation() {
    local message="$1"
    while true; do
        read -p "$message (y/n): " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            return 0
        elif [[ $REPLY =~ ^[Nn]$ ]]; then
            return 1
        else
            print_error "Invalid input. Please enter 'y' or 'n'."
        fi
    done
}

# =============================================================================
# FILE PROCESSING FUNCTIONS
# =============================================================================

# Process a single file
process_single_file() {
    local file="$1"
    local filename=$(basename "$file")
    
    print_process "Processing file: $file"
    
    # Extract EXIF data
    local exif_data=$(extract_exif_data "$file")
    local datetime=$(echo "$exif_data" | cut -d'|' -f1)
    local subsec=$(echo "$exif_data" | cut -d'|' -f2)
    local extension=$(echo "$exif_data" | cut -d'|' -f3)
    
    # Check if datetime was extracted successfully
    if [[ -z "$datetime" ]]; then
        print_error "This file doesn't have DateTimeOriginal value"
        return 1
    fi
    
    # Generate new filename
    local new_filename=$(generate_new_filename "$datetime" "$subsec" "$extension")
    
    # Display filename comparison
    print_original "Original name: $filename"
    print_success "New name: $new_filename"
    
    # Ask for confirmation and rename
    if ask_confirmation "Rename file?"; then
        mv "$file" "$(dirname "$file")/$new_filename"
        print_success "File renamed successfully!"
    else
        print_warning "Rename cancelled."
    fi
    
    return 0
}

# Process multiple files in a directory
process_directory() {
    local dir="$1"
    
    # Get list of files in directory
    local files=($(find "$dir" -type f))
    local file_count=${#files[@]}
    
    print_info "Number of files to process: $file_count"
    echo -e "${COLOR_INFO}Files:${COLOR_RESET}"
    printf "${COLOR_INFO}  %s${COLOR_RESET}\n" "${files[@]}"
    echo "----------------------------------------"
    
    # Ask for confirmation before processing
    print_warning "Press Ctrl+C to cancel at any time"
    if ! ask_confirmation "Rename files?"; then
        print_warning "Operation cancelled by user."
        exit 0
    fi
    
    print_process "Starting file processing..."
    
    # Initialize counters
    local renamed_files=0
    local unchanged_files=0
    local files_with_error=0
    
    # Process each file
    for file in "${files[@]}"; do
        echo "Processing file: $file"
        
        # Extract EXIF data
        local exif_data=$(extract_exif_data "$file")
        local datetime=$(echo "$exif_data" | cut -d'|' -f1)
        local subsec=$(echo "$exif_data" | cut -d'|' -f2)
        local extension=$(echo "$exif_data" | cut -d'|' -f3)
        
        # Check if datetime was extracted successfully
        if [[ -z "$datetime" ]]; then
            print_error "This file doesn't have DateTimeOriginal value"
            ((files_with_error++))
            continue
        fi
        
        # Generate new filename
        local new_filename=$(generate_new_filename "$datetime" "$subsec" "$extension")
        local filename=$(basename "$file")
        
        # Check if filename is already correct
        if [[ "$filename" == "$new_filename" ]]; then
            print_warning "Skipping file: $filename (already has correct name)"
            ((unchanged_files++))
            continue
        fi
        
        # Rename the file
        print_process "Original name: $filename"
        mv "$file" "$(dirname "$file")/$new_filename"
        print_success "New name:      $new_filename"
        ((renamed_files++))
    done
    
    # Display summary
    echo "----------------------------------------"
    echo -e "${COLOR_SUCCESS}✅  Renamed:  $renamed_files${COLOR_RESET}"
    echo -e "${COLOR_WARNING}⚠️   Skipped:  $unchanged_files${COLOR_RESET}"
    echo -e "${COLOR_ERROR}❌  Errors:   $files_with_error${COLOR_RESET}"
    echo "----------------------------------------"
}

# =============================================================================
# MAIN SCRIPT
# =============================================================================

main() {
    # Check dependencies
    check_exiftool
    
    # Parse arguments
    local path="$1"
    
    # Validate input
    if [[ -z "$path" ]]; then
        print_error "Please provide a file or directory path"
        echo -e "${COLOR_INFO}Usage: $0 [path to a file or directory]${COLOR_RESET}"
        exit 1
    fi
    
    # Process based on path type
    if [[ -f "$path" ]]; then
        # Process single file
        process_single_file "$path"
    elif [[ -d "$path" ]]; then
        # Process directory
        process_directory "$path"
    else
        print_error "Path doesn't exist or is neither file nor directory"
        exit 1
    fi
}

# Run main function with all arguments
main "$@"
