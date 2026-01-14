# winbat

My personal Windows CLI toolkit. Clone once, install, done.

## Installation

```batch
git clone https://github.com/Jeffrey0117/winbat.git C:\dev\winbat
cd C:\dev\winbat
install.bat
```

Restart terminal. All tools available.

## Uninstall

```batch
cd C:\dev\winbat
uninstall.bat
```

## Tools

| Command | Description |
|---------|-------------|
| `cc` | Launch Claude Code in current directory |
| `typee` | Editor Abstraction Layer - open files with any editor |

### typee

```batch
typee file.txt            # type (print)
typee --vs file.txt       # VS Code
typee --cursor file.txt   # Cursor
typee --editors           # list available editors
```

See [typee/README.md](typee/README.md) for full docs.

### cc

```batch
cc                        # launch Claude Code here
```

## Adding New Tools

1. Create `mytool.bat` or `mytool.cmd` in root, or
2. Create `mytool/` folder with `mytool.bat` inside
3. Commit & push
4. On other machines: `git pull`

## Sync to Another Machine

```batch
git clone https://github.com/Jeffrey0117/winbat.git C:\dev\winbat
C:\dev\winbat\install.bat
```

## License

MIT
