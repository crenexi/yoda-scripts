# Install

Add this to `.bashrc`

```bash
# Crenexi scripts
function path_from_crenexi() {
  cx_dirs=("cxa" "cxg" "cxi" "cxr" "cxx")

  for dir in "${cx_dirs[@]}"; do
    export PATH="$HOME/bin/$dir:$PATH"
  done
}

path_from_crenexi
```

# Groups

### CXX
| **System** checks and runs

```bash
cxx-vars.sh # Basic system vars
cxx-versions.sh # Important versions
cxx-verify.sh # Important CLIs
cxx-battery.sh # Laptop battery
```

### CXG
| **Crenexi Git** Utilities

```
cxg-release-start.sh
cxg-release-finish.sh
```

### CXR
| **Crenexi React** Utilities

```
cxr-component [dest] [name]
cxr-container [dest] [name]
```

### CXA
| **Crenexi Assets** Utilities

```
cxa-upload
```

### CXI
| **Crenexi Image** Utilities

```
WORK IN PROGRESS
# cxi-ogs-to-triple.sh [dir]
```

# Aliases

(Latest **.bashrc** backed up in DropBox)

### List

- **ls** basics: `ls`, `lv`, `ll`
- **ls** almost all: `lsa`, `lva`, `lla`
- **dir**: `di`, `div`, `dil`

### Git

- Status, branches, log: `gis`, `gib`, `gil`
- Add and commit: `gia`, `giA`, `gic`
- Git flow: `gff`, `gfr`, `gfb`, `gfh`, `gfl`

### Node

- NPM start: `nps`
- NPM build: `npb`
- NPM lint: `npl`

### Misc

- Enabled services: `sys-enabled`
- NordVPN: `nv`, `nvs`, `nvc`, `nvd`
- Copy/paste: `setclip` and `getclip`
- Matrix: cmatrix
