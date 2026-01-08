@echo off
REM OpenUSD Environment Setup Script Generator for Windows (MinSizeRel)
REM Creates and installs setup-usd-env.bat to dist-minsizerel-ms\

setlocal enabledelayedexpansion

REM Get script directory
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

REM Set paths
set "INSTALL_DIR=%SCRIPT_DIR%\dist-minsizerel-ms"
set "TBB_DIR=%SCRIPT_DIR%\dist\tbb"
set "VENV_DIR=%SCRIPT_DIR%\.venv"
set "ENV_SCRIPT=%INSTALL_DIR%\setup-usd-env.bat"

REM Check if install directory exists
if not exist "%INSTALL_DIR%" (
    echo ========================================
    echo Install directory does not exist!
    echo Please run 04-build-minsizerel.bat first
    echo ========================================
    exit /b 1
)

echo ========================================
echo Generating environment setup script
echo ========================================
echo Install directory: %INSTALL_DIR%
echo Output script: %ENV_SCRIPT%
echo ========================================

REM Get Python version from venv
set "PYTHON_VERSION="
if exist "%VENV_DIR%\Scripts\python.exe" (
    for /f "tokens=*" %%i in ('%VENV_DIR%\Scripts\python.exe -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')"') do set PYTHON_VERSION=%%i
)

REM Create the environment setup script
(
echo @echo off
echo REM OpenUSD Environment Setup Script ^(MinSizeRel^)
echo REM Run this file to set up the environment for using OpenUSD
echo REM
echo REM Usage:
echo REM   setup-usd-env.bat
echo REM
echo REM This script sets:
echo REM   - PATH: to include USD binaries
echo REM   - PYTHONPATH: to include USD Python modules
echo REM   - PXR_PLUGINPATH_NAME: for USD plugin discovery
echo.
echo REM Get the directory where this script is located
echo set "USD_INSTALL_DIR=%%~dp0"
echo set "USD_INSTALL_DIR=%%USD_INSTALL_DIR:~0,-1%%"
echo.
echo REM Try to find TBB directory
echo if exist "%%USD_INSTALL_DIR%%\..\dist\tbb" ^(
echo     set "TBB_DIR=%%USD_INSTALL_DIR%%\..\dist\tbb"
echo ^) else if exist "%%USD_INSTALL_DIR%%\tbb" ^(
echo     set "TBB_DIR=%%USD_INSTALL_DIR%%\tbb"
echo ^) else ^(
echo     set "TBB_DIR="
echo ^)
echo.
) > "%ENV_SCRIPT%"

REM Add Python version if detected
if defined PYTHON_VERSION (
    echo set "PYTHON_VERSION=%PYTHON_VERSION%" >> "%ENV_SCRIPT%"
) else (
    (
    echo REM Auto-detect Python version
    echo for /f "tokens=*" %%%%i in ^('python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}'^)"'^) do set PYTHON_VERSION=%%%%i
    ) >> "%ENV_SCRIPT%"
)

REM Continue writing the script
(
echo.
echo REM Set PATH
echo set "PATH=%%USD_INSTALL_DIR%%\bin;%%PATH%%"
echo if defined TBB_DIR set "PATH=%%TBB_DIR%%\bin;%%PATH%%"
echo.
echo REM Set PYTHONPATH
echo set "USD_PYTHON_PATH=%%USD_INSTALL_DIR%%\lib\python"
echo set "PYTHONPATH=%%USD_PYTHON_PATH%%;%%PYTHONPATH%%"
echo.
echo REM Set PXR_PLUGINPATH_NAME for plugin discovery
echo set "PXR_PLUGINPATH_NAME=%%USD_INSTALL_DIR%%\lib\usd"
echo.
echo echo ========================================
echo echo OpenUSD Environment Configured ^(MinSizeRel^)
echo echo ========================================
echo echo USD_INSTALL_DIR: %%USD_INSTALL_DIR%%
echo echo PATH includes: %%USD_INSTALL_DIR%%\bin
echo if defined TBB_DIR echo TBB PATH includes: %%TBB_DIR%%\bin
echo echo PYTHONPATH includes: %%USD_PYTHON_PATH%%
echo echo ========================================
echo echo.
echo echo Try running: usdcat --help
echo echo Or in Python: from pxr import Usd
echo echo ========================================
) >> "%ENV_SCRIPT%"

echo.
echo ========================================
echo Environment setup script created!
echo ========================================
echo Script location: %ENV_SCRIPT%
echo.
echo To use OpenUSD, run:
echo   %ENV_SCRIPT%
echo.
echo Or add to your User environment variables via System Properties
echo ========================================

endlocal
