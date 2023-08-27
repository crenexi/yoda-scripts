# Yoda Scripts

![][babyYodaGif]

Personal utility scripts.

Resources:

🛠️ **[Script Groups][urlScriptGroups]**

👨‍💻 **[Bash Aliases][urlBashAliases]**

# Setup

Add this to `.bashrc`

```bash
# Yoda scripts
function path_from_crenexi() {
  cx_dirs=("bac" "cxa" "cxg" "cxi" "cxr" "cxx")

  for dir in "${cx_dirs[@]}"; do
    export PATH="$HOME/.cx/bin/$dir:$PATH"
  done
}

path_from_crenexi
```

*Ensure all groups are included*

# Footnotes

## License

- MIT License

## Authors

* **James Blume** - [Crenexi](https://github.com/crenexi)

[babyYodaGif]: https://media.giphy.com/media/KziKCpvrGngHbYjaUF/giphy.gif
[urlScriptGroups]: https://crenexi.notion.site/Script-Groups-80b79ccfc88144c3b848fc6a2a25443a
[urlBashAliases]: https://crenexi.notion.site/Bash-Aliases-a2e9c58fc2f24b4ba482c01956e1628b





















