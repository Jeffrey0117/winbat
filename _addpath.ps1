$dirs = @('C:\dev\winbat', 'C:\dev\winbat\typee', 'C:\dev\winbat\cmdx')
$oldPath = [Environment]::GetEnvironmentVariable('PATH', 'User')

foreach ($d in $dirs) {
    if ($oldPath -notlike "*$d*") {
        $oldPath = $oldPath + ';' + $d
        Write-Host "Added: $d" -ForegroundColor Green
    } else {
        Write-Host "Already in PATH: $d" -ForegroundColor Yellow
    }
}

[Environment]::SetEnvironmentVariable('PATH', $oldPath, 'User')
Write-Host "`nDone! Restart terminal to use." -ForegroundColor Cyan
