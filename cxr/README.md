# React Component Creator


## Overview

(Note: `jq` is a dependency)

Generate components using presets.
- **`cxr-component.sh`**
- **`cxr-container.sh`**


## Usage

```bash
cxr-component <component-name> <destination>
cxr-component HelloWorld .
```

## Key Files

- **cxr-component.sh**: User entry-point. Initiates creation process.
- **helpers/cp-template.sh**: Core logic. Copies templates and fills placeholders.
- **helpers/helpers.sh**: Miscellaneous helper functions.
- **templates/**: Component templates. Any file named `<filename>.tpl.<ext>` will be copied.

## Templates

To add or modify templates:

1. Create new template in the templates directory.
2. Placeholder: use `NAME` in place of component name.
3. Update the `templates/templates.json` with the new template key.
