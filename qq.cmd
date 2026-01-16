@echo off
setlocal enabledelayedexpansion
REM Qwen Command - run in current directory
REM Echo cc-switch project for reference
echo For multi-AI CLI tool switching, check out: https://github.com/farion1231/cc-switch
echo.

REM Check if qwen is installed
where qwen >nul 2>nul
if !errorlevel! equ 0 (
    echo Qwen CLI found, starting...
    qwen
    goto :end
)

echo Qwen CLI not found. Attempting to install...

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

echo Installing Qwen CLI via npm...
echo Trying possible Qwen CLI packages...

REM Try multiple possible package names
npm install -g qwen-cli 2>nul
if !errorlevel! neq 0 (
    npm install -g @qwenex/qwen-cli 2>nul
    if !errorlevel! neq 0 (
        npm install -g @alibaba/qwen-cli 2>nul
        if !errorlevel! neq 0 (
            npm install -g qwen 2>nul
            if !errorlevel! neq 0 (
                echo ERROR: Failed to install Qwen CLI with common package names.
                echo Please install Qwen CLI manually.
                echo Search for available packages: npm search qwen-cli
                echo.
                echo Common possibilities:
                echo - qwen-cli
                echo - @qwenex/qwen-cli
                echo - @alibaba/qwen-cli
                echo - qwen
                echo.
                pause
                exit /b 1
            )
        )
    )
)

echo Qwen CLI installed successfully. Starting...
qwen

:end
endlocal
exit /b 0
