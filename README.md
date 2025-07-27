# Media File Renamer

A simple bash script that renames photo and video files based on their EXIF metadata. The script extracts the `DateTimeOriginal` and `SubSecTimeOriginal` values from media files and renames them to a standardized format: `YYYYMMDD_HHMMSS_SSS.ext`.

## Features

- ✅ **Single file processing**: Rename individual media files
- ✅ **Batch processing**: Process entire directories of media files
- ✅ **EXIF metadata extraction**: Uses DateTimeOriginal for accurate timestamps
- ✅ **Subsecond precision**: Includes subseconds for precise timing
- ✅ **Error handling**: Gracefully handles files without EXIF data
- ✅ **Interactive confirmation**: Ask for user confirmation before renaming
- ✅ **Colorized output**: Easy-to-read colored terminal output
- ✅ **Progress tracking**: Shows processing status and summary statistics
- ✅ **Skip duplicates**: Automatically skips files that already have the correct name

## Prerequisites

### macOS
```bash
brew install exiftool
```

### Linux (Ubuntu/Debian)
```bash
sudo apt-get install libimage-exiftool-perl
```

### Linux (CentOS/RHEL)
```bash
sudo yum install perl-Image-ExifTool
```

## Installation

1. Clone or download the script
2. Make it executable:
   ```bash
   chmod +x rename.sh
   ```

## Usage

### Single File
```bash
./rename.sh /path/to/photo.jpg
```

### Directory (Batch Processing)
```bash
./rename.sh /path/to/photos/
```

## Output Format

Files are renamed to the format: `YYYYMMDD_HHMMSS_SSS.ext`

- `YYYY` - Year (4 digits)
- `MM` - Month (2 digits)
- `DD` - Day (2 digits)
- `HH` - Hour (2 digits, 24-hour format)
- `MM` - Minute (2 digits)
- `SS` - Second (2 digits)
- `SSS` - Subseconds (usually 2 or 3 digits but can be longer than 3)
- `ext` - Original file extension

### Examples

| Original Name | EXIF DateTime | New Name |
|---------------|---------------|----------|
| `IMG_1234.jpg` | 2024-03-15 14:30:25.064 | `20240315_143025_064.jpg` |
| `DSC_5678.jpg` | 2024-03-15 09:15:03.2 | `20240315_091503_2.jpg` |
| `photo.jpeg` | 2024-12-01 18:45:59 | `20241201_184559_0.jpeg` |

## Interactive Mode

When processing directories, the script will:

1. Show the number of files to process
2. List all files found
3. Ask for confirmation before proceeding
4. Display progress for each file
5. Show a summary of results

### Sample Output

```
Number of files to process: 3
Files:
  ./photos/IMG_1234.jpg
  ./photos/DSC_5678.jpg
  ./photos/vacation.jpeg
----------------------------------------

Press Ctrl+C to cancel at any time
Rename files? (y/n): y
Starting file processing...

Processing file: ./photos/IMG_1234.jpg
Original name: IMG_1234.jpg
New name:      20240315_143025_0640.jpg

Processing file: ./photos/DSC_5678.jpg
Skipping file: 20240315_091503_2000.jpg (already has correct name)

Processing file: ./photos/vacation.jpeg
Error: This file doesn't have DateTimeOriginal value

----------------------------------------
✅  Renamed: 1
⚠️  Skipped: 1
❌  Errors:  1
----------------------------------------
```

## Error Handling

The script handles various error conditions:

- **Missing exiftool**: Shows installation instructions
- **Invalid path**: Reports if the path doesn't exist
- **No EXIF data**: Skips files without DateTimeOriginal metadata
- **Already correct name**: Skips files that already have the correct format
- **Non-media files**: Silently skips files that can't be processed by exiftool

## Supported File Types

The script works with any file format that contains EXIF metadata, including:

- **Photos**: JPEG, TIFF, RAW formats (CR2, NEF, ARW, etc.)
- **Videos**: MP4, MOV, AVI (if they contain EXIF data)

## Notes

- Files are renamed in-place (same directory)
- Original files are moved, not copied
- The script preserves the original file extension
- Subseconds are padded to 4 digits for consistent sorting
- If a file doesn't have subsecond data, it defaults to "0000"

## Safety Features

- **Interactive confirmation**: Always asks before making changes
- **Preview mode**: Shows what the new names will be before renaming
- **Error recovery**: Continues processing other files if one fails
- **Graceful exit**: Use Ctrl+C to cancel at any time

## Troubleshooting

### "exiftool not found"
Install exiftool using your system's package manager (see Prerequisites section).

### "This file doesn't have DateTimeOriginal value"
The file either doesn't contain EXIF metadata or the date/time information is missing. This commonly happens with:
- Screenshots
- Downloaded images
- Edited photos where metadata was stripped
- Non-camera generated images

### Files not being renamed
Check that:
- The files contain EXIF metadata
- You have write permissions to the directory
- The files aren't already in the correct format

## What's Next

- **Optimization**: Performance improvements including:
  - Smart file filtering to pre-identify files with EXIF metadata
  - Reduced exiftool calls for better efficiency
  - Memory optimization for large batch operations
- **Command-Line Options**: Add support for various flags including:
  - `--help`: Display usage information and available options
  - `--dry-run`: Preview changes without actually renaming files
  - `--verbose`: Show detailed processing information
  - `--backup`: Create backup copies before renaming
  - `--format`: Customize rename format patterns
  - `--target-dir`: Specify output directory for renamed files
- **Progress Bar**: Display real-time progress indicator for batch operations
- **Windows Support**: Create a PowerShell or batch script version for Windows users
- **Desktop Application**: Develop a GUI application with drag-and-drop functionality for easier use
- **Logging System**: Generate detailed log files after script execution
  - List of successfully renamed files with before/after names
  - Summary of skipped files and reasons
  - Error log with problematic files and error details
  - Timestamp and execution statistics

## License

This script is provided as-is for educational and personal use.

## About EXIF Metadata

EXIF (Exchangeable image file format) is a standard for storing metadata in image and video files. The `DateTimeOriginal` field contains the timestamp when the photo was taken, making it more accurate than file modification dates.

For more information about EXIF metadata, see: https://www.cipa.jp/e/std/std-sec.html 
