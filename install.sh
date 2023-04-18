# Installs all of these scripts at ~/bin

scripts_names=(
  "release-start"
  "release-finish"
)

for name in "${scripts_names[@]}"
do
  cp ./$name.sh ~/bin
  chmod +x ~/bin/$name.sh
done
