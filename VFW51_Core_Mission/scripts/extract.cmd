@echo off
rem *******************************************************************************************
rem
rem extract.cmd: .miz content extraction tool
rem
rem see usage below for further details
rem
rem *******************************************************************************************

setlocal enableDelayedExpansion

if exist %cd%/src goto InMissionDir
echo This script must be run from the base mission directory. Unable to locate src directory.
exit /be 1
:InMissionDir

rem ======== parse command line

set ARG_WX=0
set ARG_OPT=0
set ARG_SP=""
set ARG_MIZ=""
set ARG_SCRIPT=""
set ARG_LUADEBUG=1
set ARG_LUATRACE=1

:ParseArgs
if "%~1" == "" (
    goto ParseDone
) else if "%~1" == "--help" (
    goto Usage
) else if "%~1" == "--wx" (
    if %ARG_OPT% == 1 goto Usage
    set ARG_WX=1
    set LUA_DATA=--wx
) else if "%~1" == "--opt" (
    if %ARG_WX% == 1 goto Usage
    set ARG_OPT=1
    set LUA_DATA=--opt
) else if "%~1" == "--sp" (
    if "%~2" == "" goto Usage
    set ARG_SP=%~2
    set LUA_DATA=--sp %~2
    shift
) else if "%~1" == "--luadebug" (
    set ARG_LUADEBUG=1
) else if "%~1" == "--luatrace" (
    set ARG_LUATRACE=1
) else if %ARG_MIZ% == "" (
    set ARG_MIZ=%~1
) else if %ARG_SCRIPT% == "" (
    set ARG_SCRIPT=%~1
) else (
    goto Usage
)
shift
goto ParseArgs
:ParseDone

if %ARG_WX% == 0 if %ARG_OPT% == 0 goto Usage
if exist %ARG_MIZ% goto GoodMiz
echo Unable to open .miz '%ARG_MIZ%` 1>&2
goto Usage
:GoodMiz
if exist %ARG_SCRIPT% goto GoodScript
echo Unable to access script directory '%ARG_SCRIPT%` 1>&2
goto Usage
:GoodScript

rem ======== set up variables

if [%VFW51_7ZIP_EXE%] == []  set VFW51_7ZIP_EXE=7z
if [%VFW51_LUA_EXE%] == [] set VFW51_LUA_EXE=lua54
if [%VFW51_LUA_LOG%] == [] (
    if %ARG_LUATRACE% == 1 set VFW51_LUA_LOG=--trace
    if %ARG_LUADEBUG% == 1 set VFW51_LUA_LOG=--debug
)

rem ======== extract stuff

set MIZ_EXT_PATH=%cd%\extract_miz_tmp

rmdir /s /q %MIZ_EXT_PATH% >nul 2>&1
mkdir %MIZ_EXT_PATH% >nul 2>&1

"%VFW51_7ZIP_EXE%" x -y %ARG_MIZ% -o"%MIZ_EXT_PATH%\" >nul 2>&1
if %ERRORLEVEL% == 0 goto UnpackSuccess
echo Extraction fails with error %ERRORLEVEL% 1>&2
rmdir /s /q %MIZ_EXT_PATH% >nul 2>&1
exit /be %ERRORLEVEL%
:UnpackSuccess

pushd %ARG_SCRIPT%
%VFW51_LUA_EXE% VFW51MissionExtractinator.lua %LUA_DATA% %MIZ_EXT_PATH% %VFW51_LUA_LOG%
popd

rmdir /s /q %MIZ_EXT_PATH% >nul 2>&1

exit /be 0

:Usage
echo.
echo Usage: extract [--help] [--wx] [--opt] [--sp {group}] [--luadebug, --luatrace]
echo                {miz_path} {script_path}
echo.
echo TODO
echo.
echo Command line arguments:
echo.
echo   --help               Displays this usage information.
echo   --wx                 Extract weather information
echo   --opt                Extract mission options
echo   --sp {group}         Extract steerpoints for group {group}
echo   {miz_path}           Path to .miz to extract the information from
echo   {script_path}        Path to workflow Lua scripting directory (scripts\lua)
echo   --luatrace           Use "--trace" for Lua logging
echo   --luadebug           Use "--debug" for Lua logging
echo.
echo Environment variables:
echo.
echo   VFW51_7ZIP_EXE       7-zip executable (default "7z")
echo   VFW51_LUA_EXE        Lua console executable (default "lua54")
echo   VFW51_LUA_LOG        Lua support logging switches (default none), options
echo                            --trace     Enable trace log output
echo                            --debug     Enable debug log output
echo.

exit /be -1