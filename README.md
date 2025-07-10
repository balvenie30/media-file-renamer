- [Media File Renamer](#media-file-renamer)
  - [Features](#features)
  - [Filename Format](#filename-format)
  - [Prerequisites](#prerequisites)
    - [macOS](#macos)
    - [Ubuntu/Debian](#ubuntudebian)
    - [CentOS/RHEL](#centosrhel)
  - [Installation](#installation)
  - [Usage](#usage)
  - [Supported File Types](#supported-file-types)
  - [Example](#example)
  - [Limitations](#limitations)
  - [License](#license)


# Media File Renamer

A simple bash script that automatically renames photo and video files using their embedded metadata timestamps, converting generic camera filenames like `IMG_1234.jpg` to organized date-based names like `2024-03-15_14-30-22-000.jpg`.

## Features

- **Automatic timestamp extraction** from photo and video metadata (EXIF `CreateDate` or `DateTimeOriginal`)
- **Handles duplicate timestamps** (e.g., burst mode photos) with automatic numbering (`_1`, `_2`, etc.)
- **Wide format support** for photos (JPG, PNG, HEIC, RAW formats) and videos (MP4, MOV, AVI, etc.)
- **Precise filenames**: includes fractional seconds if available
- **Skips files already in the correct format**
- **Colored output** for easy reading
- **Graceful handling** of files without metadata (prints a warning and skips)

## Filename Format

The script renames files to:

```
YYYY-MM-DD_HH-MM-SS-FFF.EXT
```
- `YYYY` = year
- `MM` = month
- `DD` = day
- `HH` = hour (24h)
- `MM` = minute
- `SS` = second
- `FFF` = fractional seconds (or `000` if not present)
- `EXT` = original file extension

**Example:**
```
2024-12-31_01-04-12-123.jpg
```

## Prerequisites

- [exiftool](https://exiftool.org/) must be installed and available in your PATH.

### macOS
```bash
brew install exiftool
```

### Ubuntu/Debian
```bash
sudo apt-get install exiftool
```

### CentOS/RHEL
```bash
sudo yum install perl-Image-ExifTool
```

## Installation

1. Download the script:
```bash
wget https://raw.githubusercontent.com/yourusername/media-date-renamer/main/rename.sh
```

2. Make it executable:
```bash
chmod +x rename.sh
```

## Usage

```bash
# Rename files in the current directory
./rename.sh

# Rename files in a specific directory
./rename.sh /path/to/photos
```

- The script will process all supported files in the given directory (default: current directory).
- Files already named in the correct format will be skipped.
- Files without metadata will be skipped with a warning.
- If multiple files have the same timestamp, suffixes like `_1`, `_2`, etc. will be added.

## Supported File Types

**Photos:**
- `.jpg`, `.jpeg`, `.png`, `.gif`, `.bmp`, `.tiff`, `.tif`, `.heic`, `.heif`, `.cr2`, `.nef`, `.arw`, `.orf`

**Videos:**
- `.mp4`, `.mov`, `.avi`, `.mkv`, `.wmv`, `.flv`, `.webm`, `.3gp`, `.m4v`, `.mpg`, `.mpeg`

## Example

**Before:**
```
IMG_1234.jpg
IMG_1235.jpg
VID_20240315_143022.mp4
2024-11-10 12_12-27-33.JPG
```

**After running:**
```bash
./rename.sh
```

**After:**
```
2024-03-15_14-30-22-000.jpg
2024-03-15_14-30-22-000_1.jpg
2024-03-15_14-30-22-000.mp4
2024-11-10_12-27-33-000.jpg
```

## Limitations

- Only processes files in the specified directory (does not recurse into subdirectories).
- Only renames files with supported extensions.
- Only uses `CreateDate` or `DateTimeOriginal` EXIF fields for timestamp.
- No dry-run, backup, or custom format options.
- If no metadata is found, the file is skipped with a warning.

## License

MIT License
