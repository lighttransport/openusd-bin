@echo off
REM OpenUSD CMake Configuration Script for Windows (MinSizeRel)
REM Build Type: MinSizeRel (optimized for minimal size)
REM Custom Namespace: pxr_lte
REM Library Prefix: lte
REM Monolithic build enabled

setlocal enabledelayedexpansion

REM Get script directory
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

REM Set paths
set "SOURCE_DIR=%SCRIPT_DIR%\openusd"
set "BUILD_DIR=%SCRIPT_DIR%\build-minsizerel"
set "INSTALL_DIR=%SCRIPT_DIR%\dist-minsizerel-ms"
set "TBB_ROOT=%SCRIPT_DIR%\dist\tbb"
set "VENV_DIR=%SCRIPT_DIR%\.venv"

REM Check if source exists
if not exist "%SOURCE_DIR%" (
    echo ========================================
    echo ERROR: OpenUSD source not found at %SOURCE_DIR%
    echo ========================================
    echo Please run 01-checkout.bat first
    echo ========================================
    exit /b 1
)

REM Check if TBB exists
if not exist "%TBB_ROOT%\include\oneapi\tbb.h" (
    echo ========================================
    echo ERROR: TBB not found at %TBB_ROOT%
    echo ========================================
    echo Please run 02-download-tbb.bat first
    echo ========================================
    exit /b 1
) else (
    echo Using existing TBB at %TBB_ROOT%
)

REM Setup Python environment using uv
echo ========================================
echo Setting up Python environment with uv
echo ========================================

where uv >nul 2>&1
if errorlevel 1 (
    echo ERROR: uv is not installed. Please install uv first:
    echo   powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
    exit /b 1
)

REM Create virtual environment if it doesn't exist
if not exist "%VENV_DIR%" (
    echo Creating virtual environment at %VENV_DIR%...
    uv venv "%VENV_DIR%"
)

REM Get Python executable from venv
set "PYTHON_EXECUTABLE=%VENV_DIR%\Scripts\python.exe"
if not exist "%PYTHON_EXECUTABLE%" (
    echo ERROR: Python executable not found in venv
    exit /b 1
)

REM Get Python version
for /f "tokens=*" %%i in ('%PYTHON_EXECUTABLE% -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')"') do set PYTHON_VERSION=%%i
echo Using Python %PYTHON_VERSION% from %VENV_DIR%

REM Install required Python packages
echo Installing required Python packages...
uv pip install --python "%PYTHON_EXECUTABLE%" PyOpenGL jinja2

REM Create build directory if it doesn't exist
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"

REM Set TBB environment variable for FindTBB module
set "TBB_INSTALL_DIR=%TBB_ROOT%"

REM Change to build directory
cd /d "%BUILD_DIR%"

echo.
echo ========================================
echo Configuring OpenUSD with CMake
echo ========================================
echo Source: %SOURCE_DIR%
echo Build: %BUILD_DIR%
echo Install: %INSTALL_DIR%
echo TBB: %TBB_ROOT%
echo Python: %PYTHON_EXECUTABLE%
echo Build Type: MinSizeRel
echo Custom Namespace: pxr_lte
echo Library Prefix: lte
echo Monolithic: ON
echo ========================================

REM Detect generator
where ninja >nul 2>&1
if %errorlevel% equ 0 (
    set "GENERATOR=Ninja"
) else (
    set "GENERATOR=Visual Studio 17 2022"
)

REM Configure with CMake
cmake -G "%GENERATOR%" ^
    -DCMAKE_INSTALL_PREFIX="%INSTALL_DIR%" ^
    -DCMAKE_BUILD_TYPE=MinSizeRel ^
    -DPXR_SET_EXTERNAL_NAMESPACE=pxr_lte ^
    -DPXR_LIB_PREFIX=lte ^
    -DPXR_BUILD_MONOLITHIC=ON ^
    -DPXR_ENABLE_PYTHON_SUPPORT=ON ^
    -DPXR_USE_DEBUG_PYTHON=OFF ^
    -DBUILD_SHARED_LIBS=ON ^
    -DTBB_USE_DEBUG_BUILD=OFF ^
    -DTBB_ROOT_DIR="%TBB_ROOT%" ^
    -DPython3_EXECUTABLE="%PYTHON_EXECUTABLE%" ^
    -DPXR_BUILD_TESTS=OFF ^
    -DPXR_BUILD_EXAMPLES=OFF ^
    -DPXR_BUILD_TUTORIALS=OFF ^
    -DPXR_BUILD_DOCUMENTATION=OFF ^
    -DPXR_BUILD_USD_TOOLS=ON ^
    -DPXR_BUILD_IMAGING=OFF ^
    -DPXR_BUILD_USD_IMAGING=OFF ^
    -DPXR_BUILD_USDVIEW=OFF ^
    -DPXR_BUILD_ALEMBIC_PLUGIN=OFF ^
    -DPXR_BUILD_DRACO_PLUGIN=OFF ^
    -DPXR_ENABLE_MATERIALX_SUPPORT=OFF ^
    -DPXR_ENABLE_PTEX_SUPPORT=OFF ^
    -DPXR_ENABLE_OPENVDB_SUPPORT=OFF ^
    -DPXR_BUILD_OPENIMAGEIO_PLUGIN=OFF ^
    -DPXR_BUILD_OPENCOLORIO_PLUGIN=OFF ^
    -DPXR_BUILD_EMBREE_PLUGIN=OFF ^
    -DPXR_ENABLE_VULKAN_SUPPORT=OFF ^
    "%SOURCE_DIR%"

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo CMake configuration completed successfully!
    echo ========================================
    echo Build directory: %BUILD_DIR%
    echo.
    echo Next step: Run 04-build-minsizerel.bat
    echo ========================================
) else (
    echo ========================================
    echo CMake configuration failed!
    echo ========================================
    exit /b 1
)

endlocal
