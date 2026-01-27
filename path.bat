@echo off
setlocal EnableDelayedExpansion

if "%~1"=="" goto :help
if "%~1"=="add" goto :add
if "%~1"=="remove" goto :remove
if "%~1"=="list" goto :list
goto :help

:add
if "%~2"=="" (
  echo Usage: path add ^<directory^>
  exit /b 1
)
set "DIR=%~2"
powershell -Command "$p = [Environment]::GetEnvironmentVariable('PATH', 'User'); if ($p -like '*%DIR%*') { Write-Host 'Already in PATH: %DIR%' -ForegroundColor Yellow } else { [Environment]::SetEnvironmentVariable('PATH', $p + ';%DIR%', 'User'); Write-Host 'Added: %DIR%' -ForegroundColor Green; Write-Host 'Restart terminal to apply.' -ForegroundColor Cyan }"
exit /b 0

:remove
if "%~2"=="" (
  echo Usage: path remove ^<directory^>
  exit /b 1
)
set "DIR=%~2"
powershell -Command "$p = [Environment]::GetEnvironmentVariable('PATH', 'User'); $parts = $p -split ';' | Where-Object { $_ -ne '%DIR%' }; $newPath = $parts -join ';'; [Environment]::SetEnvironmentVariable('PATH', $newPath, 'User'); Write-Host 'Removed: %DIR%' -ForegroundColor Green; Write-Host 'Restart terminal to apply.' -ForegroundColor Cyan"
exit /b 0

:list
echo.
echo User PATH:
echo.
powershell -Command "$p = [Environment]::GetEnvironmentVariable('PATH', 'User'); $p -split ';' | ForEach-Object { if ($_) { Write-Host \"  $_\" } }"
echo.
exit /b 0

:help
echo.
echo path - Manage user PATH
echo.
echo Usage:
echo   path add ^<dir^>      Add directory to PATH
echo   path remove ^<dir^>   Remove directory from PATH
echo   path list           List user PATH entries
echo.
exit /b 0
