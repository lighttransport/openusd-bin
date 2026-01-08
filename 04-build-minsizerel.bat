@echo off
REM OpenUSD Build and Install Script for Windows (MinSizeRel)
REM Builds the configured OpenUSD project and installs to dist-minsizerel-ms\

setlocal enabledelayedexpansion

REM Get script directory
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

REM Set paths
set "BUILD_DIR=%SCRIPT_DIR%\build-minsizerel"
set "INSTALL_DIR=%SCRIPT_DIR%\dist-minsizerel-ms"

REM Check if build directory exists
if not exist "%BUILD_DIR%" (
    echo ========================================
    echo Build directory does not exist!
    echo Please run 03-configure-minsizerel.bat first
    echo ========================================
    exit /b 1
)

REM Change to build directory
cd /d "%BUILD_DIR%"

REM Get number of cores
set "NUM_CORES=%NUMBER_OF_PROCESSORS%"

echo ========================================
echo Building OpenUSD (MinSizeRel)
echo ========================================
echo Build directory: %BUILD_DIR%
echo Install directory: %INSTALL_DIR%
echo Build Type: MinSizeRel
echo Using %NUM_CORES% parallel jobs
echo ========================================

REM Build and install
cmake --build . --config MinSizeRel --target install -j %NUM_CORES%

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo Build and install completed successfully!
    echo ========================================
    echo Install location: %INSTALL_DIR%
    echo.
    echo To check library size:
    echo   dir "%INSTALL_DIR%\lib\lteusd_ms.dll"
    echo.
    echo To generate environment script:
    echo   05-setup-env-minsizerel.bat
    echo ========================================
) else (
    echo ========================================
    echo Build failed!
    echo ========================================
    exit /b 1
)

endlocal
