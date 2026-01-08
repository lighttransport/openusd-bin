@echo off
REM TBB Build Script for Windows
REM Downloads and builds Intel oneTBB from source
REM Build Type: RelWithDebInfo

setlocal enabledelayedexpansion

REM Get script directory
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

REM Set paths
set "TBB_INSTALL_DIR=%SCRIPT_DIR%\dist\tbb"
set "TBB_SRC_DIR=%SCRIPT_DIR%\tbb-src"
set "TBB_BUILD_DIR=%SCRIPT_DIR%\tbb-build"

REM TBB version and URL
set "TBB_VERSION=v2021.12.0"
set "TBB_URL=https://github.com/oneapi-src/oneTBB/archive/refs/tags/%TBB_VERSION%.tar.gz"

echo ========================================
echo Building Intel oneTBB from source
echo ========================================
echo Version: %TBB_VERSION%
echo Install Directory: %TBB_INSTALL_DIR%
echo Source Directory: %TBB_SRC_DIR%
echo Build Directory: %TBB_BUILD_DIR%
echo ========================================

REM Download TBB if not already present
if not exist "%TBB_SRC_DIR%" (
    echo Downloading TBB...

    REM Download using PowerShell
    powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%TBB_URL%' -OutFile 'tbb.tar.gz'}"

    if errorlevel 1 (
        echo Error: Failed to download TBB
        exit /b 1
    )

    echo Extracting TBB...
    REM Extract using tar (available in Windows 10+)
    tar -xzf tbb.tar.gz

    REM Rename directory
    for /d %%d in (oneTBB-*) do (
        move "%%d" "%TBB_SRC_DIR%"
    )

    del tbb.tar.gz
    echo Download complete: %TBB_SRC_DIR%
) else (
    echo Using existing TBB source at %TBB_SRC_DIR%
)

REM Create build directory
if not exist "%TBB_BUILD_DIR%" mkdir "%TBB_BUILD_DIR%"
cd /d "%TBB_BUILD_DIR%"

REM Get number of cores
set "NUM_CORES=%NUMBER_OF_PROCESSORS%"

echo.
echo ========================================
echo Configuring TBB with CMake
echo ========================================
echo Build Type: RelWithDebInfo
echo Parallel Jobs: %NUM_CORES%
echo ========================================

REM Detect generator
where ninja >nul 2>&1
if %errorlevel% equ 0 (
    set "GENERATOR=Ninja"
) else (
    set "GENERATOR=Visual Studio 17 2022"
)

REM Configure TBB with CMake
cmake -G "%GENERATOR%" ^
    -DCMAKE_INSTALL_PREFIX="%TBB_INSTALL_DIR%" ^
    -DCMAKE_BUILD_TYPE=RelWithDebInfo ^
    -DTBB_TEST=OFF ^
    -DTBB_STRICT=OFF ^
    -DBUILD_SHARED_LIBS=ON ^
    "%TBB_SRC_DIR%"

if errorlevel 1 (
    echo ========================================
    echo TBB CMake configuration failed!
    echo ========================================
    exit /b 1
)

echo.
echo ========================================
echo Building TBB
echo ========================================

REM Build and install TBB
cmake --build . --config RelWithDebInfo --target install -j %NUM_CORES%

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo TBB build completed successfully!
    echo ========================================
    echo Install location: %TBB_INSTALL_DIR%
    echo.
    echo Next step: Run 03-configure-minsizerel.bat
    echo ========================================
) else (
    echo ========================================
    echo TBB build failed!
    echo ========================================
    exit /b 1
)

endlocal
