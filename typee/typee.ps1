# typee - Editor Abstraction Layer v3
# Auto-detect editors using Everything (es.exe)
# Features: JSON config, caching, priority, --editors

param(
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$Params
)

$Option = if ($Params.Count -gt 0) { $Params[0] } else { "" }
$File = if ($Params.Count -gt 1) { $Params[1] } else { "" }

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigFile = Join-Path $ScriptDir "config.json"
$CacheFile = Join-Path $env:TEMP "typee_cache.json"

# Load config
$Config = @{
    editors = @{
        vs     = @{ exe = "Code.exe"; priority = 2 }
        cursor = @{ exe = "Cursor.exe"; priority = 1 }
        wind   = @{ exe = "Windsurf.exe"; priority = 3 }
        anti   = @{ exe = "Antigravity.exe"; priority = 4 }
    }
    default = "cursor"
    cache_hours = 24
}

if (Test-Path $ConfigFile) {
    $json = Get-Content $ConfigFile -Raw | ConvertFrom-Json
    $Config.default = $json.default
    $Config.cache_hours = $json.cache_hours
    foreach ($prop in $json.editors.PSObject.Properties) {
        $Config.editors[$prop.Name] = @{
            exe = $prop.Value.exe
            priority = $prop.Value.priority
        }
    }
}

# Find es.exe
function Find-EsExe {
    $es = Get-Command "es.exe" -ErrorAction SilentlyContinue
    if ($es) { return $es.Source }

    $wingetDir = Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Packages"
    $found = Get-ChildItem -Path $wingetDir -Recurse -Filter "es.exe" -ErrorAction SilentlyContinue |
             Where-Object { $_.FullName -match "Everything.Cli" } |
             Select-Object -First 1
    if ($found) { return $found.FullName }
    return $null
}

# Load cache
function Get-Cache {
    if (-not (Test-Path $CacheFile)) { return @{ paths = @{} } }
    try {
        $json = Get-Content $CacheFile -Raw | ConvertFrom-Json
        $cache = @{ paths = @{}; timestamp = $json.timestamp }
        foreach ($prop in $json.paths.PSObject.Properties) {
            $cache.paths[$prop.Name] = $prop.Value
        }
        $expiry = (Get-Date).AddHours(-$Config.cache_hours)
        if ([DateTime]$cache.timestamp -lt $expiry) { return @{ paths = @{} } }
        return $cache
    } catch {
        return @{ paths = @{} }
    }
}

# Save cache
function Save-Cache($cache) {
    $cache.timestamp = (Get-Date).ToString("o")
    $cache | ConvertTo-Json | Set-Content $CacheFile
}

# Find editor path (with caching)
function Find-Editor($exeName) {
    $cache = Get-Cache
    if ($cache.paths -and $cache.paths.$exeName) {
        $path = $cache.paths.$exeName
        if (Test-Path $path) { return $path }
    }

    $es = Find-EsExe
    if (-not $es) { return $null }

    $results = & $es $exeName 2>$null | Where-Object { $_ -notmatch "Prefetch|\\Windows\\|Recycle" } | Select-Object -First 1
    if ($results -and (Test-Path $results -ErrorAction SilentlyContinue)) {
        $result = $results
        if (-not $cache.paths) { $cache.paths = @{} }
        $cache.paths.$exeName = $result
        Save-Cache $cache
        return $result
    }
    return $null
}

# Show help
function Show-Help {
    Write-Host "typee - Editor Abstraction Layer v3" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: typee [option] <file>"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  (none)      type (CLI print)"
    Write-Host "  --m         more"
    Write-Host "  --n         Notepad"
    Write-Host "  --e         Default editor ($($Config.default))"
    foreach ($key in $Config.editors.Keys | Sort-Object { $Config.editors[$_].priority }) {
        $ed = $Config.editors[$key]
        Write-Host "  --$key".PadRight(14) "$($ed.exe) [priority: $($ed.priority)]"
    }
    Write-Host ""
    Write-Host "  --editors   List available editors"
    Write-Host "  --cache     Show cache status"
    Write-Host "  --clear     Clear cache"
}

# List available editors
function Show-Editors {
    Write-Host "Available Editors:" -ForegroundColor Cyan
    Write-Host ""
    $sorted = $Config.editors.Keys | Sort-Object { $Config.editors[$_].priority }
    foreach ($key in $sorted) {
        $ed = $Config.editors[$key]
        $path = Find-Editor $ed.exe
        if ($path) {
            Write-Host "  [OK] --$key".PadRight(18) -ForegroundColor Green -NoNewline
            Write-Host $path
        } else {
            Write-Host "  [--] --$key".PadRight(18) -ForegroundColor DarkGray -NoNewline
            Write-Host "$($ed.exe) not found" -ForegroundColor DarkGray
        }
    }
}

# Show cache status
function Show-Cache {
    $cache = Get-Cache
    Write-Host "Cache Status:" -ForegroundColor Cyan
    Write-Host "  File: $CacheFile"
    if ($cache.timestamp) {
        Write-Host "  Updated: $($cache.timestamp)"
        Write-Host "  Expires: $($Config.cache_hours) hours after update"
        Write-Host ""
        Write-Host "Cached paths:"
        foreach ($key in $cache.paths.Keys) {
            Write-Host "  $key -> $($cache.paths[$key])"
        }
    } else {
        Write-Host "  (empty)"
    }
}

# Main logic
if (-not $Option) {
    Show-Help
    exit 0
}

switch ($Option) {
    "--editors" { Show-Editors; exit 0 }
    "--cache"   { Show-Cache; exit 0 }
    "--clear"   { Remove-Item $CacheFile -ErrorAction SilentlyContinue; Write-Host "Cache cleared."; exit 0 }
    "--m"       { if ($File) { more $File } else { Write-Host "Error: No file specified" }; exit 0 }
    "--n"       { if ($File) { Start-Process notepad $File } else { Write-Host "Error: No file specified" }; exit 0 }
    "--e"       { $Option = "--$($Config.default)" }
}

# No flag = type
if ($Option -notmatch "^--") {
    type $Option
    exit 0
}

# Editor mode
$editorKey = $Option -replace "^--", ""
if (-not $Config.editors.ContainsKey($editorKey)) {
    Write-Host "Unknown option: $Option" -ForegroundColor Red
    exit 1
}

if (-not $File) {
    Write-Host "Error: No file specified" -ForegroundColor Red
    exit 1
}

$exeName = $Config.editors[$editorKey].exe
$editorPath = Find-Editor $exeName

if ($editorPath) {
    Start-Process $editorPath $File
} else {
    Write-Host "[typee] $exeName not found, falling back to Notepad" -ForegroundColor Yellow
    Start-Process notepad $File
}
