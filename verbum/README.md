# Verbum

A small macOS desktop widget that shows a New Testament passage (King James Version) and changes it every four hours.

## Install

```bash
bash install.sh
```

The installer compiles the widget with Xcode Command Line Tools. If they are missing, macOS asks to install them. In that case, install them and run the command again.

## Use

- Drag the widget under your desktop widgets and let go. It snaps into line.
- Right-click it to copy the passage, snap or fine-tune its position, reset it, or quit.
- To change how often the passage changes, edit `let hoursPerPassage = 4` in `install.sh` and run the installer again.

## Remove

```bash
bash install.sh --uninstall
```
