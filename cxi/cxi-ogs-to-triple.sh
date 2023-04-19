# This script takes an image (ex. "cat_og.png") and creates two more images
# of size 1920w and 1040w, then applies a light compression. The parameter
# is the directory, where this will be applied to the whole directory

function produce {
  name=$1
  width=$2
  if [[ -z "$name" ]]; then exit; fi
  if [[ -z "$width" ]]; then exit; fi

  src="${name}_og.${ext}"
  file_og="${name}_${width}_og.$ext"
  file="${name}_${width}.$ext"

  convert "$src" -resize "${width}x" "$file_og"
  ffmpeg -i "$file_og" -compression_level 75 -y "$file"
}

function each_ext {
  dir=$1
  ext=$2

  if [[ -z "$dir" || -z "$ext" ]]; then exit; fi

  shopt -s nullglob
  for f in "$dir"/*."$ext"; do
    basename=$(basename "$f" ".$ext")
    name=$(echo "$basename" | sed -e "s/_og//g")
    width=$(identify -format "%w" $f)

    # Compress the original
    ffmpeg -i "$f" -compression_level 85 -y "$name.$ext"

    # Produce size variations
    if [ "$width" -gt 1920 ]; then produce $name 1920; fi
    if [ "$width" -gt 1040 ]; then produce $name 1040; fi
  done
  shopt -u nullglob
}

each_ext $1 "png"
each_ext $1 "jpg"
