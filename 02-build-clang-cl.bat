@echo off
REM Build a minimal OpenUSD 26.05 LTE Windows x64 package with clang-cl,
REM the MSVC linker, Windows SDK, and UCRT from a Visual Studio environment.

setlocal

set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
if not defined OPENUSD_SOURCE_DIR set "OPENUSD_SOURCE_DIR=%SCRIPT_DIR%\openusd"
if not defined BUILD_ROOT set "BUILD_ROOT=%SCRIPT_DIR%\build-clang-cl"
if not defined INSTALL_PREFIX set "INSTALL_PREFIX=%SCRIPT_DIR%\dist-clang-cl"
if not defined ONETBB_VERSION set "ONETBB_VERSION=2021.12.0"
if not defined JOBS set "JOBS=%NUMBER_OF_PROCESSORS%"

set "TBB_ARCHIVE=oneTBB-%ONETBB_VERSION%.zip"
set "TBB_URL=https://github.com/oneapi-src/oneTBB/archive/refs/tags/v%ONETBB_VERSION%.zip"
set "TBB_SOURCE_DIR=%BUILD_ROOT%\oneTBB-%ONETBB_VERSION%"
set "TBB_BUILD_DIR=%BUILD_ROOT%\tbb-build"
set "USD_BUILD_DIR=%BUILD_ROOT%\usd-build"

if not exist "%OPENUSD_SOURCE_DIR%\CMakeLists.txt" (
    echo error: OpenUSD source not found at %OPENUSD_SOURCE_DIR% 1>&2
    echo Run 01-checkout-clang-cl.bat first. 1>&2
    exit /b 1
)

where clang-cl.exe >nul 2>&1 || (echo error: clang-cl.exe not found 1>&2 & exit /b 1)
where link.exe >nul 2>&1 || (echo error: MSVC link.exe not found 1>&2 & exit /b 1)
where cmake.exe >nul 2>&1 || (echo error: cmake.exe not found 1>&2 & exit /b 1)
where ninja.exe >nul 2>&1 || (echo error: ninja.exe not found 1>&2 & exit /b 1)
where curl.exe >nul 2>&1 || (echo error: curl.exe not found 1>&2 & exit /b 1)
where tar.exe >nul 2>&1 || (echo error: tar.exe not found 1>&2 & exit /b 1)

echo clang-cl compiler:
clang-cl.exe --version
echo MSVC linker:
where link.exe
echo Windows SDK: %WindowsSdkDir%

if not exist "%BUILD_ROOT%" mkdir "%BUILD_ROOT%"
if not exist "%INSTALL_PREFIX%" mkdir "%INSTALL_PREFIX%"

if not exist "%TBB_SOURCE_DIR%\CMakeLists.txt" (
    if not exist "%BUILD_ROOT%\%TBB_ARCHIVE%" (
        curl.exe -fL --retry 3 -o "%BUILD_ROOT%\%TBB_ARCHIVE%" "%TBB_URL%"
        if errorlevel 1 exit /b 1
    )
    tar.exe -xf "%BUILD_ROOT%\%TBB_ARCHIVE%" -C "%BUILD_ROOT%"
    if errorlevel 1 exit /b 1
)

cmake -S "%TBB_SOURCE_DIR%" -B "%TBB_BUILD_DIR%" -G Ninja ^
    -DCMAKE_C_COMPILER=clang-cl.exe ^
    -DCMAKE_CXX_COMPILER=clang-cl.exe ^
    -DCMAKE_LINKER=link.exe ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDLL ^
    -DCMAKE_INSTALL_PREFIX="%INSTALL_PREFIX%" ^
    -DTBB_TEST=OFF ^
    -DTBB_STRICT=OFF ^
    -DBUILD_SHARED_LIBS=ON
if errorlevel 1 exit /b 1

cmake --build "%TBB_BUILD_DIR%" --target install -j %JOBS%
if errorlevel 1 exit /b 1

cmake -S "%OPENUSD_SOURCE_DIR%" -B "%USD_BUILD_DIR%" -G Ninja ^
    -DCMAKE_C_COMPILER=clang-cl.exe ^
    -DCMAKE_CXX_COMPILER=clang-cl.exe ^
    -DCMAKE_LINKER=link.exe ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDLL ^
    -DCMAKE_INSTALL_PREFIX="%INSTALL_PREFIX%" ^
    -DTBB_DIR="%INSTALL_PREFIX%\lib\cmake\TBB" ^
    -DBUILD_SHARED_LIBS=ON ^
    -DPXR_SET_EXTERNAL_NAMESPACE=pxr_lte ^
    -DPXR_LIB_PREFIX=lte ^
    -DPXR_BUILD_MONOLITHIC=ON ^
    -DPXR_ENABLE_PYTHON_SUPPORT=OFF ^
    -DPXR_BUILD_IMAGING=OFF ^
    -DPXR_BUILD_USD_IMAGING=OFF ^
    -DPXR_BUILD_USDVIEW=OFF ^
    -DPXR_BUILD_TESTS=OFF ^
    -DPXR_BUILD_EXAMPLES=OFF ^
    -DPXR_BUILD_TUTORIALS=OFF ^
    -DPXR_BUILD_USD_TOOLS=OFF ^
    -DPXR_BUILD_USD_VALIDATION=OFF ^
    -DPXR_BUILD_DOCUMENTATION=OFF ^
    -DPXR_BUILD_EXEC=OFF ^
    -DPXR_FIND_TBB_IN_CONFIG=ON ^
    -DPXR_ENABLE_PRECOMPILED_HEADERS=OFF ^
    -DPXR_ENABLE_COMPILER_CACHE=OFF
if errorlevel 1 exit /b 1

cmake --build "%USD_BUILD_DIR%" --target install -j %JOBS%
if errorlevel 1 exit /b 1

if not exist "%INSTALL_PREFIX%\lib\lteusd_ms.dll" (
    echo error: expected lteusd_ms.dll was not installed 1>&2
    exit /b 1
)
findstr /x /c:"#define PXR_NS pxr_lte" "%INSTALL_PREFIX%\include\pxr\pxr.h" >nul
if errorlevel 1 (
    echo error: installed headers do not use the pxr_lte namespace 1>&2
    exit /b 1
)

echo clang-cl OpenUSD installed in: %INSTALL_PREFIX%

endlocal
