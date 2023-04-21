# Installs all of these scripts at ~/bin

folders=(
  "./cxa"
  "./cxg"
  "./cxi"
  "./cxr"
)

# Script copies
for folder in "${folders[@]}"
do
  cp -r $folder ~/bin
  find ~/bin/$folder -type f -exec chmod 755 -- {} +
done
