# sync — 同步「目前所在的 git repo」:fetch → 顯示落後/領先 → 乾淨就自動 pull
# 多機開發用:坐下先打 sync,就不會改到舊版。
$ErrorActionPreference = 'SilentlyContinue'

git rev-parse --git-dir > $null 2>&1
if ($LASTEXITCODE -ne 0) { Write-Host "這裡不是 git repo" -ForegroundColor Red; exit 1 }

$branch = (git rev-parse --abbrev-ref HEAD).Trim()
$name = Split-Path (git rev-parse --show-toplevel).Trim() -Leaf
Write-Host ("{0}  [{1}]" -f $name, $branch) -ForegroundColor Cyan

Write-Host "  fetch..." -ForegroundColor DarkGray
git fetch --quiet 2>$null

$upstream = (git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>$null)
if (-not $upstream) { Write-Host "  ⚠️ 這個分支沒有 upstream(還沒 push 過)→ 首次:git push -u origin $branch" -ForegroundColor Yellow; exit 0 }

$counts = (git rev-list --left-right --count "$upstream...HEAD" 2>$null) -split '\s+'
$behind = [int]$counts[0]; $ahead = [int]$counts[1]
$dirty = ((git status --porcelain 2>$null) | Measure-Object).Count -gt 0

if ($behind -gt 0) {
  if ($dirty) {
    Write-Host "  ⚠️ 落後 $behind 個,但你有未 commit 改動 → 先 commit 或 git stash,再 sync" -ForegroundColor Yellow
  } else {
    Write-Host "  ↓ 落後 $behind → 自動 pull..." -ForegroundColor Green
    git pull --ff-only
  }
}
if ($ahead -gt 0) { Write-Host "  ↑ 你領先 $ahead 個 commit,記得 git push(注意:push 會觸發部署)" -ForegroundColor Magenta }
if ($dirty)       { Write-Host "  ✎ 有未 commit 的 WIP" -ForegroundColor Yellow }
if ($behind -eq 0 -and $ahead -eq 0 -and -not $dirty) { Write-Host "  ✅ 已同步,乾淨" -ForegroundColor Green }
