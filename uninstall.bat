@echo off
:: winbat uninstaller - removes winbat from PATH

echo.
echo  winbat uninstaller
echo  ==================
echo.

set "WINBAT_DIR=%~dp0"
set "WINBAT_DIR=%WINBAT_DIR:~0,-1%"

echo Removing from PATH: %WINBAT_DIR%

:: Remove main dir and subdirs from PATH
powershell -Command ^
    "$oldPath = [Environment]::GetEnvironmentVariable('PATH', 'User'); ^
     $newPath = ($oldPath -split ';' | Where-Object { $_ -notlike '*winbat*' }) -join ';'; ^
     [Environment]::SetEnvironmentVariable('PATH', $newPath, 'User'); ^
     Write-Host '[OK] Removed from PATH' -ForegroundColor Green"

echo.
echo NOTE: Restart your terminal for changes to take effect.
echo.
pause
