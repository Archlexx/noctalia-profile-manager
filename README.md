# Profiles

A [Noctalia](https://github.com/noctalia-dev/noctalia-shell) plugin for saving, loading, and managing shell configuration profiles.

Each profile is a named snapshot of your current Noctalia configuration: color scheme, settings, plugin state, and optionally wallpapers. Apply any profile in one click to switch your entire environment instantly.

---

![Preview](preview.png)

<video src="assets/changes_preview_video.mp4" controls width="100%"></video>

---

## Included profiles

### Caelestia
Light theme with soft blue tones and a minimalist snowy mountain wallpaper. Based on Caelestia-Shell.

![Caelestia](assets/profiles/Caelestia/preview.png)

### Darklestia
Dark theme with bold red accents and an edgy artistic wallpaper.

![Darklestia](assets/profiles/Darklestia/preview.png)

### Demon
Vivid red dark theme inspired by oni/demon aesthetics.

![Demon](assets/profiles/Demon/preview.png)

### MacOS
macOS-style layout with a bottom dock and a colorful purple-pink gradient wallpaper.

![MacOS](assets/profiles/MacOS/preview.png)

### MacOS Dark
Dark variant of the macOS-inspired theme.

![MacOS Dark](<assets/profiles/MacOS Dark/preview.png>)

### Windows 26
Dark theme with golden accents and a Windows 11-style taskbar layout.

![Windows 26](<assets/profiles/Windows 26/preview.png>)

---

## Features

- **Save profiles** — Snapshot `settings.json`, `colors.json`, `plugins.json`, and wallpapers into a named directory.
- **Apply profiles** — Restore a full configuration in one click.
- **Active profile indicator** — The last applied profile is marked with a colored accent bar and a check icon.
- **Saved-on date** — Each profile shows the date and time it was last saved.
- **Search** — Filter the profile list by name in real time.
- **Per-profile wallpaper toggle** — Each row has an independent toggle to include or exclude wallpapers when applying.
- **Auto-backup** — Before every apply, the current configuration is automatically saved to `_backups/<timestamp>/`. Backups are pruned to a configurable maximum.
- **Rename** — Rename any profile with Enter-key support.
- **Delete with confirmation** — A modal dialog prevents accidental deletions.
- **IPC support** — Control the plugin from scripts or keybinds.
- **Customizable bar icon** — Choose any Tabler icon and accent color from settings.
- **i18n** — 12 languages included (see table below).

---

## Installation

1. Copy this folder to `~/.config/noctalia/plugins/shell-profiles/`.
2. Add the plugin to `~/.config/noctalia/plugins.json`:

```json
{
  "states": {
    "shell-profiles": { "enabled": true, "sourceUrl": "local" }
  }
}
```

3. Restart Noctalia or reload plugins.

---

## Settings

| Setting | Default | Description |
|---|---|---|
| `profilesDir` | `~/.config/noctalia/profiles/` | Directory where profiles are stored |
| `icon` | `bookmark` | Tabler icon shown in the bar widget |
| `iconColor` | `primary` | Accent color for the bar icon (`primary`, `secondary`, `tertiary`, `error`) |
| `includeWallpapers` | `true` | Whether new profile rows default to applying wallpapers |
| `backupEnabled` | `true` | Create an auto-backup before each profile apply |
| `backupCount` | `5` | Maximum number of backups to keep (1–20) |

---

## Profile structure

```
~/.config/noctalia/profiles/
├── my-profile/
│   ├── settings.json
│   ├── colors.json
│   ├── plugins.json
│   ├── wallpapers.json
│   └── meta.json          ← { "savedAt": "2026-04-03T00:35:00.000Z" }
└── _backups/
    └── 2026-04-03_00-35-00/
        ├── settings.json
        ├── colors.json
        ├── plugins.json
        ├── wallpapers.json
        └── meta.json
```

Profiles whose folder name starts with `_` or `.` are hidden from the list.

---

## IPC

Send commands to the plugin from a script or keybind:

```bash
# Toggle the profiles panel
qs ipc call plugin:shell-profiles toggleProfiles

# Apply a profile by name (uses the default includeWallpapers setting)
qs ipc call plugin:shell-profiles applyProfile 'my-profile'
```

### Binding IPC to keybinds by compositor

#### Hyprland (`~/.config/hypr/hyprland.conf`)

```ini
bind = SUPER, P, exec, qs -c noctalia-shell ipc call plugin:shell-profiles toggleProfiles
bind = SUPER SHIFT, F1, exec, qs -c noctalia-shell ipc call plugin:shell-profiles applyProfile 'Darklestia'
```

#### Niri (`~/.config/niri/config.kdl`)

```kdl
binds {
    Mod+Shift+P { spawn "sh" "-c" "qs ipc call plugin:shell-profiles toggleProfiles"; }
    Mod+Shift+F1 { spawn "sh" "-c" "qs ipc call plugin:shell-profiles applyProfile 'my-profile'"; }
}
```

#### Sway (`~/.config/sway/config`)

```
bindsym $mod+Shift+p exec qs ipc call plugin:shell-profiles toggleProfiles
bindsym $mod+Shift+F1 exec qs ipc call plugin:shell-profiles applyProfile 'my-profile'
```

#### labwc (`~/.config/labwc/rc.xml`)

```xml
<keybind key="W-S-p">
  <action name="Execute">
    <command>qs ipc call plugin:shell-profiles toggleProfiles</command>
  </action>
</keybind>
<keybind key="W-S-F1">
  <action name="Execute">
    <command>qs ipc call plugin:shell-profiles applyProfile 'my-profile'</command>
  </action>
</keybind>
```

---

## Languages

| Code | Language |
|------|----------|
| `en` | English |
| `es` | Spanish |
| `de` | German |
| `fr` | French |
| `it` | Italian |
| `pt` | Portuguese |
| `nl` | Dutch |
| `ru` | Russian |
| `ja` | Japanese |
| `zh-CN` | Chinese (Simplified) |
| `tr` | Turkish |
| `uk-UA` | Ukrainian |

---
## License

MIT License