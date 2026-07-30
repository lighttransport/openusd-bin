@echo off
REM Checkout the OpenUSD v26.05 custom namespace branch for clang-cl builds.

setlocal

set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
if not defined OPENUSD_REPOSITORY set "OPENUSD_REPOSITORY=https://github.com/lighttransport/openusd.git"
if not defined OPENUSD_REF set "OPENUSD_REF=v26.05-custom-namespace"
if not defined OPENUSD_SOURCE_DIR set "OPENUSD_SOURCE_DIR=%SCRIPT_DIR%\openusd"

if exist "%OPENUSD_SOURCE_DIR%\.git" goto update
if exist "%OPENUSD_SOURCE_DIR%" (
    echo error: %OPENUSD_SOURCE_DIR% exists but is not a Git checkout 1>&2
    exit /b 1
)

git clone --branch "%OPENUSD_REF%" --single-branch "%OPENUSD_REPOSITORY%" "%OPENUSD_SOURCE_DIR%"
if errorlevel 1 exit /b 1
goto show_revision

:update
git -C "%OPENUSD_SOURCE_DIR%" fetch origin "%OPENUSD_REF%"
if errorlevel 1 exit /b 1
git -C "%OPENUSD_SOURCE_DIR%" checkout --detach FETCH_HEAD
if errorlevel 1 exit /b 1

:show_revision
echo OpenUSD source: %OPENUSD_SOURCE_DIR%
git -C "%OPENUSD_SOURCE_DIR%" log -1 --format="OpenUSD ref:    %%H"
if errorlevel 1 exit /b 1

endlocal
