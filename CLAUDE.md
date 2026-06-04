# winbat

Personal Windows CLI toolkit — a collection of `.bat`/`.cmd`/`.ps1` scripts added to PATH so they run as global commands. Clone once, run `install.bat`, done.

## Stack
- Windows Batch (`.bat` / `.cmd`) — the primary scripting language
- PowerShell — invoked inline from batch for PATH edits and richer logic (e.g. `path.bat`, `install.bat`)
- No build system, no package.json, no dependencies. Pure scripts.
- Distribution: git clone → `install.bat` adds the repo root (and each subfolder) to the **user** PATH.

## Directory structure

```
winbat/
  install.bat / uninstall.bat   ← Add/remove repo dir + subdirs to user PATH (via PowerShell)
  cc.cmd                        ← Launch Claude Code in cwd (auto-installs claude/node if missing)
  cdcc.bat                      ← cd into a dir, then run cc
  clonecc.bat                   ← git clone a repo, cd in, then run cc
  desk.bat / mkcd.bat           ← Navigation helpers (cd to Desktop / mkdir+cd)
  ip.bat / ports.bat ports.ps1  ← Show local IPv4 / listening ports
  path.bat                      ← Manage user PATH: add | remove | list
  gg.cmd / qq.cmd               ← Misc command shortcuts
  _addpath.ps1                  ← PowerShell PATH helper
  cmdx/                         ← 42 Unix commands as .bat shims (ls, cat, grep, ...)
  typee/                        ← Editor abstraction layer (typee.bat/.ps1 + config.json)
```

Note: `UsersjeffbDesktopcodecmdx/` and `UsersjeffbDesktopcodewcmd/` are empty stray dirs (no files); not part of the toolkit.

## Key concepts

- **PATH-based dispatch**: Every script lives on PATH, so its filename *is* the command. `install.bat` walks the root for `*.bat`/`*.cmd` and adds every subdirectory too, so `cmdx/` and `typee/` commands become available.
- **cmdx graceful fallback**: Each `cmdx/*.bat` is generated (by the external [cmdx](https://github.com/Jeffrey0117/cmdx) tool / "shellmap"). Pattern: probe for a better modern tool with `where`, use it if present, else fall back to the Windows native command. Example `ls`: tries `yazi` → `lsd` → `eza` → `dir`. Do not hand-edit these; regenerate via cmdx and copy in.
- **cc auto-bootstrap**: `cc.cmd` checks for `claude`, then `npm`/`node`, and will `winget install OpenJS.NodeJS` + `npm i -g @anthropic-ai/claude-code` if needed before launching.
- **endlocal trick**: `clonecc.bat`/`cdcc.bat` use `endlocal & cd /d ... & call cc` so the directory change survives `setlocal` and persists in the caller's shell.
- **typee**: Editor abstraction — `typee/config.json` maps editor keys (cursor/vs/wind/anti) to exe names with priorities and a `cache_hours` for detection; opens files with the chosen/available editor.
- **Sibling projects**: cmdx (Unix→Windows generator), winbat (this toolkit), wcmd (Windows→Linux). See README for links.

## Commands

There is no build/test step. Working on this repo means editing scripts and testing them in a terminal.

```batch
install.bat              :: add winbat (and subdirs) to user PATH — restart terminal after
uninstall.bat            :: remove all winbat entries from user PATH
path list                :: inspect current user PATH entries
```

Adding a new tool: drop `mytool.bat`/`mytool.cmd` in the root (or a `mytool/` folder containing `mytool.bat`), commit, then `git pull` + re-run `install.bat` on other machines (re-run needed only if a new subdir was added).

## Coding rules

- Start scripts with `@echo off`; use `setlocal enabledelayedexpansion` when reading vars set inside `if`/`for` blocks (reference with `!var!`, not `%var%`).
- Escape special chars in `echo` for batch: `^<`, `^>`, `^|`, `^(`, `^)`.
- For permanent PATH / environment changes, shell out to PowerShell `[Environment]::SetEnvironmentVariable(..., 'User')` rather than `setx` — preserves existing PATH and avoids truncation.
- Always `where <tool> >nul 2>&1` to detect optional tools before using them; provide a native fallback.
- Set explicit `exit /b <code>` so chaining (`||`, `&&`) works for callers.
- Keep cmdx-generated files (`cmdx/*.bat`) machine-generated; regenerate, don't hand-patch.
