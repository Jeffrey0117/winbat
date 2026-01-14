@echo off
:: winbat installer - adds winbat to PATH

echo.
echo  winbat installer
echo  ================
echo.

:: Get the directory where this script is located
set "WINBAT_DIR=%~dp0"
set "WINBAT_DIR=%WINBAT_DIR:~0,-1%"

:: Check if already in PATH
echo %PATH% | findstr /i /c:"%WINBAT_DIR%" >nul
if %errorlevel%==0 (
    echo [OK] winbat is already in PATH
    echo     %WINBAT_DIR%
    goto :done
)

:: Add to user PATH (permanent)
echo Adding to PATH: %WINBAT_DIR%
echo.

:: Use PowerShell to add to user PATH permanently
powershell -Command ^
    "$oldPath = [Environment]::GetEnvironmentVariable('PATH', 'User'); ^
     if ($oldPath -notlike '*%WINBAT_DIR%*') { ^
         $newPath = $oldPath + ';%WINBAT_DIR%'; ^
         [Environment]::SetEnvironmentVariable('PATH', $newPath, 'User'); ^
         Write-Host '[OK] Added to user PATH (permanent)' -ForegroundColor Green ^
     }"

:: Also add subdirectories (typee, etc.)
for /d %%d in ("%WINBAT_DIR%\*") do (
    echo Adding: %%d
    powershell -Command ^
        "$oldPath = [Environment]::GetEnvironmentVariable('PATH', 'User'); ^
         if ($oldPath -notlike '*%%d*') { ^
             $newPath = $oldPath + ';%%d'; ^
             [Environment]::SetEnvironmentVariable('PATH', $newPath, 'User'); ^
         }"
)

echo.
echo [OK] Installation complete!
echo.
echo NOTE: Restart your terminal to use the new commands.

:done
echo.
echo Available tools:
echo.
for %%f in ("%WINBAT_DIR%\*.bat") do (
    if /i not "%%~nxf"=="install.bat" if /i not "%%~nxf"=="uninstall.bat" (
        echo   - %%~nf
    )
)
for /d %%d in ("%WINBAT_DIR%\*") do (
    echo   - %%~nxd
)
echo.
pause
