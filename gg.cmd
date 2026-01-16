@echo off
setlocal enabledelayedexpansion
REM Gemini Command - run in current directory
REM Echo cc-switch project for reference
echo For multi-AI CLI tool switching, check out: https://github.com/farion1231/cc-switch
echo.

REM Check if gemini is installed
where gemini >nul 2>nul
if !errorlevel! equ 0 (
    echo Gemini CLI found, starting...
    gemini
    goto :end
)

echo Gemini CLI not found. Attempting to install...

REM Check if npm is available
where npm >nul 2>nul
if !errorlevel! neq 0 (
    echo npm not found. Checking for Node.js...

    REM Check if Node.js is installed
    where node >nul 2>nul
    if !errorlevel! neq 0 (
        echo Node.js not found. Installing via winget...

        REM Check if winget is available
        where winget >nul 2>nul
        if !errorlevel! neq 0 (
            echo ERROR: winget not available. Cannot install Node.js.
            echo Please install Node.js manually from https://nodejs.org/
            pause
            exit /b 1
        )

        echo Installing Node.js via winget (this may take a while^)...
        winget install OpenJS.NodeJS
        if !errorlevel! neq 0 (
            echo ERROR: Failed to install Node.js via winget.
            echo Please install Node.js manually from https://nodejs.org/
            pause
            exit /b 1
        )

        echo Node.js installed successfully.
    )

    echo npm should now be available.
)

echo Installing Gemini CLI via npm...
echo Trying common Gemini CLI packages...

REM Try multiple possible package names
npm install -g @anthropic-ai/gemini-cli 2>nul
if !errorlevel! neq 0 (
    npm install -g gemini-cli 2>nul
    if !errorlevel! neq 0 (
        npm install -g @google/gemini-cli 2>nul
        if !errorlevel! neq 0 (
            echo ERROR: Failed to install Gemini CLI with common package names.
            echo Please install Gemini CLI manually.
            echo Common packages: gemini-cli, @google/gemini-cli
            echo Or search: npm search gemini-cli
            pause
            exit /b 1
        )
    )
)

echo Gemini CLI installed successfully. Starting...
gemini

:end
endlocal
exit /b 0
