#!/bin/bash
set -e

ACTUALLY_CONVERT=1
IMAGE_WIDTH=775
BORDER_WIDTH=4
BORDER_COLOR="black"

IMAGE_WIDTH=$((IMAGE_WIDTH - (2*BORDER_WIDTH)))

# +-----------------------------------
# Functions
# +-----------------------------------
check_usage() {
  if !command -v convert &> /dev/null
  then
    echo "The 'convert' command could not be found:"
    echo "  For Debian-based: 'sudo apt install imagemagick'"
    echo "  For Arch: 'sudo pacman -S imagemagick'"
  fi

  if !command -v identify &> /dev/null
  then
    echo "The 'identify' command could not be found."
    echo "  For Debian-based: 'sudo apt install imagemagick'"
    echo "  For Arch: 'sudo pacman -S imagemagick'"
  fi

  if [[ -z $1 ]];
  then
    print_usage
  fi

  if [[ ! -d "${1}" ]]
  then
    echo
    echo "The images directory does not exist: ${1}"
    echo
    print_usage
  fi
}

print_usage() {
  echo "Usage: $0 image_dir [destination]"
  echo
  echo "This will resize and add a border to all images in the :image_dir:. The results"
  echo "will be saved in :destination: if provided. If a file already exists in :destination:"
  echo "with the desired name, a new file will be created with an incrementing file name"
  echo "e.g. file.png exists so file_0.png will be created."
  echo
  echo "image_dir:   directory path to the images that will be converted"
  echo "destination: directory where converted images are saved"
  echo "             if not provided a directory named 'converted_images' will"
  echo "             be created in the same location as 'images'. If this is not a"
  echo "             path then it will be used as the name of the created directory."
  echo
  echo "Examples:"
  echo "./report_images.sh ~/temp/convert/images  -> Output will be in ~/temp/convert/converted_images"
  echo "./report_images.sh ~/temp/convert/images test  -> Output will be in ~/temp/convert/test"
  echo "./report_images.sh ~/temp/convert/images ~/test  -> Output will be in ~/test"
  exit 1
}

# Converts image.
# $1 = Source
# $2 = Dest
convert_file() {
  if [[ $ACTUALLY_CONVERT -eq 1 ]]
  then
    local width=$(identify -format "%[width]" "$1")
    if [[ $width -gt $IMAGE_WIDTH ]]
    then
      convert "$1" -resize $IMAGE_WIDTH -bordercolor $BORDER_COLOR -border $BORDER_WIDTH "$2"
      echo "converted $DEST_PATH"
    else
      convert "$1" -bordercolor $BORDER_COLOR -border $BORDER_WIDTH "$2"
      echo "converted $DEST_PATH"
    fi
  else
    echo "converting $SOURCE_PATH to $DEST_PATH"
  fi
}

# Function that establishes the SOURCE_PATH and DEST_PATH for each file
file_input_output_paths() {
  SOURCE_PATH=$(realpath "${1}")
  FILE_NAME=$(basename "${1}")
  DEST_PATH="$OUTPUT_DIR/$FILE_NAME"
  if [[ -f "$DEST_PATH" ]]
  then
    local i=0
    FILE_PATH_NO_EXT="${DEST_PATH%.*}"
    EXTENSION="${FILE_NAME##*.}"
    while [[ -f "${FILE_PATH_NO_EXT}_${i}.$EXTENSION" ]]
    do
      # echo "${FILE_PATH_NO_EXT}_${i}.$EXTENSION exists"
      i=$((i + 1))
    done
    DEST_PATH="${FILE_PATH_NO_EXT}_${i}.$EXTENSION"
  fi
}

# Establishes an output directory
get_output_dir() {
  PARENT_DIR=$(dirname $1)
  OUTPUT_DIR=""
  if (($# == 2));
  then
    if [[ ! $2 =~ "/" ]]
    then
      OUTPUT_DIR="${PARENT_DIR}/${2}"
    else
      OUTPUT_DIR="$(realpath ${2})"
    fi
    if [[ ! -d $OUTPUT_DIR ]]
    then
      echo "Creating directory: $OUTPUT_DIR"
      mkdir "$OUTPUT_DIR"
    fi
  else
    OUTPUT_DIR="${PARENT_DIR}/converted_images"
    if [[ ! -d "$OUTPUT_DIR" ]]
    then
      echo "Creating directory: $OUTPUT_DIR"
      mkdir "$OUTPUT_DIR"
    fi
  fi
}

loop_image_files() {
  extensions=(png jpg)
  for extension in ${extensions[@]}
  do
    for f in ${1}/*.${extension}; do
      if [[ -f "$f" ]]
      then
        file_input_output_paths "$f"
        convert_file "$SOURCE_PATH" "$DEST_PATH"
      fi
    done;
  done;
}

# +-----------------------------------
# Main
# +-----------------------------------
check_usage $1
if (($# == 2));
then
  get_output_dir $1 $2
else
  get_output_dir $1
fi
loop_image_files $1
