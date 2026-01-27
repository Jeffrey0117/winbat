@echo off
if "%~1"=="" (
  echo Usage: mkcd ^<directory^>
  exit /b 1
)
mkdir "%~1" 2>nul
cd /d "%~1"
