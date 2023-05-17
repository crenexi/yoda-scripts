# Installs all of these scripts at ~/bin

folders=(
  "./cxa"
  "./cxg"
  "./cxi"
  "./cxr"
  "./cxx"
)

# Script copies
for folder in "${folders[@]}"
do
  cp -r $folder ~/bin
  find ~/bin/$folder -type f -name "*.sh" -exec chmod 755 -- {} +
done

source ~/.bashrc
