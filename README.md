# Named Workspaces

A HyDe-style workspace switcher for the Omarchy bar. Instead of always showing
every workspace number, it shows only the workspaces that are **occupied**
(have windows open) or **focused**, with the title of each workspace's focused
window right next to its number.

```
 2  Firefox       1  OC | Omarchy w…   3
```

- Focused workspace: number highlighted in the accent color
- Occupied workspaces: dimmed number + last focused window title
- Focused-but-empty workspace: number only, no title
- Empty workspaces are hidden entirely
- Workspaces are scoped to the focused monitor
- Vertical bars show numbers only

## Install

```sh
omarchy plugin add https://github.com/murdialthaf/omarchy-named-workspaces.git --enable
```

## Usage

Click a workspace number **or its window title** to switch to that workspace.
Hover a title for the full window name.

## Configure

The window title is truncated to 15 characters by default. Adjust it per
instance in `~/.config/omarchy/shell.json`:

```json
{
  "bar": {
    "layout": {
      "left": [
        { "id": "omarchy.menu" },
        { "id": "murdi.named-workspaces", "maxChars": 20 }
      ]
    }
  }
}
```

The bar hot-reloads `shell.json` on save — no restart needed. Move the widget
between bar sections with:

```sh
omarchy bar move murdi.named-workspaces --section right
```

## Remove

```sh
omarchy plugin remove murdi.named-workspaces
```

## License

MIT
