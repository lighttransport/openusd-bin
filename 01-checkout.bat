@echo off
REM OpenUSD Checkout Script for Windows
REM Clones the lighttransport/openusd repository

setlocal enabledelayedexpansion

REM Get script directory
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

REM Set paths
set "OPENUSD_SRC_DIR=%SCRIPT_DIR%\openusd"

echo ========================================
echo Cloning OpenUSD from lighttransport
echo ========================================
echo Repository: https://github.com/lighttransport/openusd
echo Target directory: %OPENUSD_SRC_DIR%
echo ========================================

if exist "%OPENUSD_SRC_DIR%" (
    echo Directory %OPENUSD_SRC_DIR% already exists.
    set /p "REPLY=Do you want to update it? (y/n): "
    if /i "!REPLY!"=="y" (
        echo Updating existing repository...
        cd /d "%OPENUSD_SRC_DIR%"
        git fetch origin
        git pull origin main
    ) else (
        echo Using existing repository.
    )
) else (
    echo Cloning repository...
    git clone https://github.com/lighttransport/openusd.git "%OPENUSD_SRC_DIR%"
)

echo.
echo ========================================
echo Checkout completed successfully!
echo ========================================
echo Source location: %OPENUSD_SRC_DIR%
echo.
echo Next step: Run 02-download-tbb.bat
echo ========================================

endlocal
