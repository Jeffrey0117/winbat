@echo off
if "%~1"=="" (
  echo Usage: cdcc ^<directory^>
  exit /b 1
)
cd /d "%~1" || exit /b 1
call cc
