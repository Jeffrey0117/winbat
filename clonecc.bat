@echo off
setlocal enabledelayedexpansion
if "%~1"=="" (
  echo Usage: clonecc ^<repo-url^> [directory]
  exit /b 1
)

if not "%~2"=="" (
  git clone "%~1" "%~2" || exit /b 1
  endlocal & cd /d "%~2" & call cc
  exit /b 0
)

set "URL=%~1"
if "!URL:~-4!"==".git" set "URL=!URL:~0,-4!"
for %%i in ("!URL:/=" "!") do set "REPONAME=%%~i"

git clone "%~1" || exit /b 1
endlocal & cd /d "%REPONAME%" & call cc
