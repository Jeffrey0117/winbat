# typee

**Editor Abstraction Layer** - One command, multiple editors.

Switch editors by changing a flag, not your muscle memory.

## Why?

Today you use VS Code, Cursor, Windsurf, Antigravity...
Tomorrow you switch to something new.
With `typee`, you change nothing. It just works.

## Features

- Auto-detects editor paths using [Everything](https://www.voidtools.com/) (`es.exe`)
- Zero configuration - no PATH editing, no manual paths
- **v3: JSON config** - customize editors, priority, cache duration
- **v3: Caching** - editor paths cached for 24h (configurable)
- **v3: Priority** - set preferred editor order
- **v3: --editors** - list all available editors
- Fallback to Notepad if editor not found

## Requirements

- Windows
- [Everything](https://www.voidtools.com/) installed and running
- [Everything CLI (es.exe)](https://www.voidtools.com/support/everything/command_line_interface/) in PATH

```batch
winget install voidtools.Everything
winget install voidtools.Everything.Cli
```

## Installation

1. Clone this repo (or just grab the files)
2. Add the folder to your PATH

```batch
git clone https://github.com/Jeffrey0117/typee.git C:\dev\typee
```

## Usage

```batch
typee test.txt            # type (print to CLI)
typee --m test.txt        # more
typee --n test.txt        # Notepad
typee --e test.txt        # Default editor (from config)

typee --vs test.txt       # VS Code
typee --cursor test.txt   # Cursor
typee --wind test.txt     # Windsurf
typee --anti test.txt     # Antigravity

typee --editors           # List available editors
typee --cache             # Show cache status
typee --clear             # Clear cache
```

## Configuration

Edit `config.json` to customize:

```json
{
  "editors": {
    "vs": { "exe": "Code.exe", "priority": 2 },
    "cursor": { "exe": "Cursor.exe", "priority": 1 },
    "wind": { "exe": "Windsurf.exe", "priority": 3 },
    "anti": { "exe": "Antigravity.exe", "priority": 4 }
  },
  "default": "cursor",
  "cache_hours": 24
}
```

- **priority**: Lower = higher priority (shown first in `--editors`)
- **default**: Which editor `--e` uses
- **cache_hours**: How long to cache editor paths

### Adding New Editors

Just add to `config.json`:

```json
"zed": { "exe": "Zed.exe", "priority": 5 }
```

Then use: `typee --zed myfile.txt`

## How It Works

1. You run `typee --vs myfile.txt`
2. Checks cache for `Code.exe` path
3. If not cached, calls `es.exe` to find it
4. Caches the result for 24 hours
5. Launches the editor with your file
6. If not found, falls back to Notepad

## License

MIT
