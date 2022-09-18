@echo off
rem *******************************************************************************************
rem
rem build.cmd: mission .miz build tool
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

set ARG_BASE=0
set ARG_DIRTY=0
set ARG_DRY_RUN=0
set ARG_DYNAMIC=0
set ARG_LUADEBUG=0
set ARG_LUATRACE=0
set ARG_NOSYNC=0
set ARG_TAG=0
set ARG_VERBOSE=0

:ParseArgs
if "%~1" == "" (
    goto ParseDone
) else if "%~1" == "--help" (
    goto Usage
) else if "%~1" == "--base" (
    set ARG_BASE=1
) else if "%~1" == "--dirty" (
    set ARG_DIRTY=1
    set SYNC_ARGS=%SYNC_ARGS% --dirty
) else if "%~1" == "--dryrun" (
    set ARG_DRY_RUN=1
    set ARG_VERBOSE=1
    set SYNC_ARGS=%SYNC_ARGS% --dryrun
) else if "%~1" == "--dynamic" (
    set ARG_DYNAMIC=1
    set LUA_DYNAMIC=--dynamic
    set SYNC_ARGS=%SYNC_ARGS% --dynamic
) else if "%~1" == "--nosync" (
    set ARG_NOSYNC=1
) else if "%~1" == "--luadebug" (
    set ARG_LUADEBUG=1
    set SYNC_ARGS=%SYNC_ARGS% --luadebug
) else if "%~1" == "--luatrace" (
    set ARG_LUATRACE=1
    set SYNC_ARGS=%SYNC_ARGS% --luatrace
) else if "%~1" == "--tag" (
    if "%~2" == "" goto Usage
    if "%~2" == "0" goto Usage
    set ARG_TAG=%~2
    set LUA_TAG=--tag %~2
    shift
) else if "%~1" == "--verbose" (
    set ARG_VERBOSE=1
    set SYNC_ARGS=%SYNC_ARGS% --verbose
) else (
    goto Usage
)
shift
goto ParseArgs
:ParseDone

rem ======== set up variables

if [%VFW51_7ZIP_EXE%] == []  set VFW51_7ZIP_EXE=7z
if [%VFW51_LUA_EXE%] == [] set VFW51_LUA_EXE=lua54
if [%VFW51_LUA_LOG%] == [] (
    if %ARG_LUATRACE% == 1 set VFW51_LUA_LOG=--trace
    if %ARG_LUADEBUG% == 1 set VFW51_LUA_LOG=--debug
)

rem extracts the mission name from the path to the current directory.
for /f %%i in ('%VFW51_LUA_EXE% scripts\lua\VFW51WorkflowGetMission.lua %cd%') do set MISSION_NAME=%%i

set MISSION_BASE=%cd%
set MISSION_SRC=%MISSION_BASE%\src
set MIZ_EXT_PATH=%MISSION_BASE%\src\miz_core
set MIZ_BLD_PATH=%MISSION_BASE%\build\miz_image
set MIZ_BLD_DFLT_PATH=%MIZ_BLD_PATH%\l10n\DEFAULT

rem ======== sync mission

if %ARG_NOSYNC% == 1 goto SyncDone
if %ARG_VERBOSE% == 1 echo call scripts\sync.cmd %SYNC_ARGS%
if %ARG_DRY_RUN% == 0 call scripts\sync.cmd %SYNC_ARGS%
:SyncDone

rem ======== build mission

echo.
echo ========================================================
echo Building .miz File(s) for %MISSION_NAME%
echo ========================================================
echo.
echo VFW51_7ZIP_EXE   %VFW51_7ZIP_EXE%
echo VFW51_LUA_EXE    %VFW51_LUA_EXE%
echo VFW51_LUA_LOG    %VFW51_LUA_LOG%
echo.
echo MISSION_SRC      %MISSION_SRC%
echo MIZ_BLD_PATH     %MIZ_BLD_PATH%
echo.

if %ARG_DRY_RUN% == 1 echo **** NOTE: --dryrun, no changes will be made...
if %ARG_DRY_RUN% == 1 echo.

echo ---- Preparing mission folder
if exist %MISSION_BASE%\backup goto SkipBackupMkdir
if %ARG_VERBOSE% == 1 echo mkdir %MISSION_BASE%\backup
if %ARG_DRY_RUN% == 0 mkdir %MISSION_BASE%\backup >nul 2>&1
:SkipBackupMkdir

if %ARG_VERBOSE% == 1 echo rmdir /s /q %MISSION_BASE%\build
if %ARG_DRY_RUN% == 0 rmdir /s /q %MISSION_BASE%\build >nul 2>&1

if %ARG_VERBOSE% == 1 echo mkdir %MISSION_BASE%\build
if %ARG_DRY_RUN% == 0 mkdir %MISSION_BASE%\build >nul 2>&1

rem we will operate on the files in the build/ directory, not the src/ directory. copy
rem everything over first before making any modifications.

echo ---- Copying files
if %ARG_VERBOSE% == 1 echo xcopy /y /e %MIZ_EXT_PATH% %MIZ_BLD_PATH%\
if %ARG_DRY_RUN% == 0 xcopy /y /e %MIZ_EXT_PATH% %MIZ_BLD_PATH%\ >nul 2>&1

if %ARG_VERBOSE% == 1 echo xcopy /y /e %MISSION_BASE%\src\audio\*.ogg %MIZ_BLD_DFLT_PATH%
if %ARG_DRY_RUN% == 0 xcopy /y /e %MISSION_BASE%\src\audio\*.ogg %MIZ_BLD_DFLT_PATH% >nul 2>&1

if %ARG_VERBOSE% == 1 echo xcopy /y /e %MISSION_BASE%\src\audio\*.wav %MIZ_BLD_DFLT_PATH%
if %ARG_DRY_RUN% == 0 xcopy /y /e %MISSION_BASE%\src\audio\*.wav %MIZ_BLD_DFLT_PATH% >nul 2>&1

if %ARG_VERBOSE% == 1 echo xcopy /y /e %MISSION_BASE%\src\briefing\*.jpg %MIZ_BLD_DFLT_PATH%
if %ARG_DRY_RUN% == 0 xcopy /y /e %MISSION_BASE%\src\briefing\*.jpg %MIZ_BLD_DFLT_PATH% >nul 2>&1

if %ARG_VERBOSE% == 1 echo xcopy /y /e %MISSION_BASE%\src\briefing\*.png %MIZ_BLD_DFLT_PATH%
if %ARG_DRY_RUN% == 0 xcopy /y /e %MISSION_BASE%\src\briefing\*.png %MIZ_BLD_DFLT_PATH% >nul 2>&1

if %ARG_VERBOSE% == 1 echo xcopy /y /e %MISSION_BASE%\src\scripts\*.lua %MIZ_BLD_DFLT_PATH%
if %ARG_DRY_RUN% == 0 xcopy /y /e %MISSION_BASE%\src\scripts\*.lua %MIZ_BLD_DFLT_PATH% >nul 2>&1

pushd %MISSION_BASE%\scripts\lua

echo ---- Updating scripting triggers
if %ARG_VERBOSE% == 1 echo %VFW51_LUA_EXE% VFW51MissionTriginator.lua %MISSION_SRC% %MIZ_BLD_PATH% %LUA_DYNAMIC% %VFW51_LUA_LOG%
if %ARG_DRY_RUN% == 0 %VFW51_LUA_EXE% VFW51MissionTriginator.lua %MISSION_SRC% %MIZ_BLD_PATH% %LUA_DYNAMIC% %VFW51_LUA_LOG%

echo ---- Injecting waypoints
if %ARG_VERBOSE% == 1 echo %VFW51_LUA_EXE% VFW51MissionWaypointinator.lua %MISSION_SRC% %MIZ_BLD_PATH% %VFW51_LUA_LOG%
if %ARG_DRY_RUN% == 0 %VFW51_LUA_EXE% VFW51MissionWaypointinator.lua %MISSION_SRC% %MIZ_BLD_PATH% %VFW51_LUA_LOG%

echo ---- Injecting radio presets
if %ARG_VERBOSE% == 1 echo %VFW51_LUA_EXE% VFW51MissionRadioinator.lua %MISSION_SRC% %MIZ_BLD_PATH% %VFW51_LUA_LOG%
if %ARG_DRY_RUN% == 0 %VFW51_LUA_EXE% VFW51MissionRadioinator.lua %MISSION_SRC% %MIZ_BLD_PATH% %VFW51_LUA_LOG%

echo ---- Injecting briefing
if %ARG_VERBOSE% == 1 echo %VFW51_LUA_EXE% VFW51MissionBriefinator.lua %MISSION_SRC% %MIZ_BLD_PATH% %VFW51_LUA_LOG%
if %ARG_DRY_RUN% == 0 %VFW51_LUA_EXE% VFW51MissionBriefinator.lua %MISSION_SRC% %MIZ_BLD_PATH% %VFW51_LUA_LOG%

echo ---- Generating and injecting kneeboards
if %ARG_VERBOSE% == 1 echo %VFW51_LUA_EXE% VFW51MissionKboardinator.lua %MISSION_SRC% %MIZ_BLD_PATH% %VFW51_LUA_LOG%
if %ARG_DRY_RUN% == 0 %VFW51_LUA_EXE% VFW51MissionKboardinator.lua %MISSION_SRC% %MIZ_BLD_PATH% %VFW51_LUA_LOG%

rem have potentially non-normal mission files ready to go in build\miz_image, now build out the
rem variants based on variant settings. this creates normalized files named
rem [options-]<mission_name>[-v<version>][-<variant>] at the top level of the build directory.
rem copy these down and pack to build the final mission.

echo ---- Building DCS ME mission files for mission versions
if %ARG_VERBOSE% == 1 echo %VFW51_LUA_EXE% VFW51MissionVariantinator.lua %MISSION_NAME% %MISSION_SRC% %MIZ_BLD_PATH% %VFW51_LUA_LOG% %LUA_TAG%
if %ARG_DRY_RUN% == 0 %VFW51_LUA_EXE% VFW51MissionVariantinator.lua %MISSION_NAME% %MISSION_SRC% %MIZ_BLD_PATH% %VFW51_LUA_LOG% %LUA_TAG%

if %ARG_BASE% == 0 set VARIANT_FILES="%MISSION_BASE%\build\%MISSION_NAME%*"
if %ARG_BASE% == 1 set VARIANT_FILES="%MISSION_BASE%\build\%MISSION_NAME%"
for %%f in (%VARIANT_FILES%) do (

    echo ---- Creating mission variant %%~nxf
    if %ARG_VERBOSE% == 1 echo xcopy /y /e %%f %MIZ_BLD_PATH%\mission
    if %ARG_DRY_RUN% == 0 xcopy /y /e %%f %MIZ_BLD_PATH%\mission >nul 2>&1
    if exist options-%%f (
        if %ARG_VERBOSE% == 1 echo xcopy /y /e options-%%f %MIZ_BLD_PATH%\options
        if %ARG_DRY_RUN% == 0 xcopy /y /e options-%%f %MIZ_BLD_PATH%\options >nul 2>&1
    ) else (
        if %ARG_VERBOSE% == 1 echo xcopy /y /e %MIZ_EXT_PATH%\options %MIZ_BLD_PATH%\options
        if %ARG_DRY_RUN% == 0 xcopy /y /e %MIZ_EXT_PATH%\options %MIZ_BLD_PATH%\options >nul 2>&1
    )

    echo Buildinator - Normalizing mission files for variant %%~nxf
    if %ARG_VERBOSE% == 1 echo %VFW51_LUA_EXE% veafMissionNormalizer.lua %MIZ_BLD_PATH% %VFW51_LUA_LOG%
    if %ARG_DRY_RUN% == 0 %VFW51_LUA_EXE% veafMissionNormalizer.lua %MIZ_BLD_PATH% %VFW51_LUA_LOG%

    echo Buildinator - Backing up previous .miz file for variant %%~nxf
    if %ARG_VERBOSE% == 1 echo xcopy /y %MISSION_BASE%\%%~nxf.miz %MISSION_BASE%\backup\
    if %ARG_DRY_RUN% == 0 xcopy /y %MISSION_BASE%\%%~nxf.miz %MISSION_BASE%\backup\ >nul 2>&1

    echo Buildinator - Packing mission into %%~nxf.miz
    if %ARG_VERBOSE% == 1 echo %VFW51_7ZIP_EXE% a -r -tzip %MISSION_BASE%\%%~nxf.miz %MIZ_BLD_PATH%\* -mem=AES256
    if %ARG_DRY_RUN% == 0 %VFW51_7ZIP_EXE% a -r -tzip %MISSION_BASE%\%%~nxf.miz %MIZ_BLD_PATH%\* -mem=AES256 >nul 2>&1
)

popd

if %ARG_DIRTY% == 1 goto SkipClean
echo ---- Cleanup temporary mission build files
if %ARG_VERBOSE% == 1 echo rmdir /s /q %MIZ_BLD_PATH%
if %ARG_DRY_RUN% == 0 rmdir /s /q %MIZ_BLD_PATH% >nul 2>&1
:SkipClean

if %ARG_DYNAMIC% == 0 goto StaticBuild
echo.
echo **** NOTE: You have built .miz file(s) that use dynamic loading of Lua scripts. Such
echo **** NOTE: versions are only appropriate for local debug and are not (typically) suitable
echo **** NOTE: for deployment on a server or different system.
:StaticBuild

exit /be 0

:Usage
echo.
echo Usage: build [--help] [--dirty] [--base] [--dynamic] [--version {version}] [--nosync]
echo              [--dryrun] [--verbose] [--luadebug, --luatrace]
echo.
echo Assemble and build the .miz mission file(s) described by the mission directory. The .miz
echo files are output at the root level of the mission directory. The sync.cmd script is
echo run before the build by default.
echo.
echo This script must be run from the root of a mission directory.
echo.
echo Command line arguments:
echo.
echo   --help               Displays this usage information
echo   --nosync             Do not run sync script prior to build
echo   --dirty              Leave the mission build directory in place after building
echo   --base               Build base mission only, do not build any other variants
echo   --dynamic            Build mission for dynamic script loading
echo   --version {version}  Add non-zero integer {version} to the .miz file name(s) as version tag
echo   --dryrun             Dry run, print but do not execute commands (implies --verbose)
echo   --verbose            Verbose logging output
echo   --luatrace           Pass "--trace" to Lua scripts to set "trace" level logging
echo   --luadebug           Pass "--debug" to Lua scripts to set "debug" level logging
echo.
echo Note --dirty, --dryrun, --dynamic, --verbose, and --luadebug/trace are passed through to sync.
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