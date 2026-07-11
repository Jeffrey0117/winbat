# syncall — 掃 Desktop\code 下所有 repo,一眼看哪些落後/領先/有WIP(換機前必看)
# 只「顯示」不自動改;要同步某個就進去打 sync。
$ErrorActionPreference = 'SilentlyContinue'
$root = "C:\Users\jeffb\Desktop\code"
if (-not (Test-Path $root)) { Write-Host "找不到 $root" -ForegroundColor Red; exit 1 }

Write-Host "掃描 $root 的 repo(逐一 fetch,稍等)..." -ForegroundColor Cyan
$any = $false
Get-ChildItem $root -Directory -Force | ForEach-Object {
  $d = $_.FullName
  if (-not (Test-Path "$d\.git")) { return }
  Push-Location $d
  git fetch --quiet 2>$null
  $u = (git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>$null)
  $behind = 0; $ahead = 0
  if ($u) { $c = (git rev-list --left-right --count "$u...HEAD" 2>$null) -split '\s+'; $behind = [int]$c[0]; $ahead = [int]$c[1] }
  $dirty = ((git status --porcelain 2>$null) | Measure-Object).Count -gt 0
  Pop-Location
  if ($behind -gt 0 -or $ahead -gt 0 -or $dirty) {
    $any = $true
    $flags = @()
    if ($behind -gt 0) { $flags += "↓$behind" }
    if ($ahead  -gt 0) { $flags += "↑$ahead" }
    if ($dirty)        { $flags += "WIP" }
    $color = if ($behind -gt 0) { 'Yellow' } elseif ($ahead -gt 0) { 'Magenta' } else { 'DarkYellow' }
    Write-Host ("  {0,-30} {1}" -f $_.Name, ($flags -join ' ')) -ForegroundColor $color
  }
}
if (-not $any) { Write-Host "  ✅ 全部同步、乾淨" -ForegroundColor Green }
Write-Host "`n(↓落後=進去打 sync 拉  ↑領先=記得 push  WIP=有未commit)" -ForegroundColor DarkGray
