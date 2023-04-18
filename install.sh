# Installs all of these scripts at ~/bin

$bin=~/bin

scripts_names=(
  "release-start"
  "release-finish",
  "cxr-component",
  "cxr-container"
)

for name in "${scripts_names[@]}"
do
  cp ./$name.sh $bin/
  chmod +x $bin/$name.sh
done

# Folder copies
cp $bin/
