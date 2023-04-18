# Installs all of these scripts at ~/bin

scripts_names=(
  "release-start"
  "release-finish"
  "cxr-component"
  "cxr-container"
)

# Folder copies
sudo cp -r ./cxr-templates/ ~/bin

# Script copies
for name in "${scripts_names[@]}"
do
  cp ./$name.sh ~/bin
  chmod +x ~/bin/$name.sh
done
