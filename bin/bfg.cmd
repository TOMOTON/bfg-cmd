@REM ----------------------------------------------------------------------------
@REM Licensed to the Apache Software Foundation (ASF) under one
@REM or more contributor license agreements.  See the NOTICE file
@REM distributed with this work for additional information
@REM regarding copyright ownership.  The ASF licenses this file
@REM to you under the Apache License, Version 2.0 (the
@REM "License"); you may not use this file except in compliance
@REM with the License.  You may obtain a copy of the License at
@REM
@REM    http://www.apache.org/licenses/LICENSE-2.0
@REM
@REM Unless required by applicable law or agreed to in writing,
@REM software distributed under the License is distributed on an
@REM "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
@REM KIND, either express or implied.  See the License for the
@REM specific language governing permissions and limitations
@REM under the License.
@REM ----------------------------------------------------------------------------

@REM ----------------------------------------------------------------------------
@REM BFG Start Up Batch script
@REM
@REM Required ENV vars:
@REM JAVA_HOME - location of a JDK home dir
@REM
@REM Optional ENV vars
@REM M2_HOME - location of BFG2's installed home dir
@REM BFG_BATCH_ECHO - set to 'on' to enable the echoing of the batch commands
@REM BFG_BATCH_PAUSE - set to 'on' to wait for a key stroke before ending
@REM BFG_OPTS - parameters passed to the Java VM when running BFG
@REM     e.g. to debug BFG itself, use
@REM set BFG_OPTS=-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=8000
@REM BFG_SKIP_RC - flag to disable loading of BFGrc files
@REM ----------------------------------------------------------------------------

@REM Begin all REM lines with '@' in case BFG_BATCH_ECHO is 'on'
@echo off
@REM enable echoing my setting BFG_BATCH_ECHO to 'on'
@if "%BFG_BATCH_ECHO%" == "on"  echo %BFG_BATCH_ECHO%

@REM set %HOME% to equivalent of $HOME
if "%HOME%" == "" (set "HOME=%HOMEDRIVE%%HOMEPATH%")

@REM Execute a user defined script before this one
if not "%BFG_SKIP_RC%" == "" goto skipRcPre
@REM check for pre script, once with legacy .bat ending and once with .cmd ending
if exist "%HOME%\BFGrc_pre.bat" call "%HOME%\BFGrc_pre.bat"
if exist "%HOME%\BFGrc_pre.cmd" call "%HOME%\BFGrc_pre.cmd"
:skipRcPre

@setlocal

set ERROR_CODE=0

@REM To isolate internal variables from possible post scripts, we use another setlocal
@setlocal

@REM ==== START VALIDATION ====
if not "%JAVA_HOME%" == "" goto OkJHome

echo.
echo Error: JAVA_HOME not found in your environment. >&2
echo Please set the JAVA_HOME variable in your environment to match the >&2
echo location of your Java installation. >&2
echo.
goto error

:OkJHome
if exist "%JAVA_HOME%\bin\java.exe" goto chkMHome

echo.
echo Error: JAVA_HOME is set to an invalid directory. >&2
echo JAVA_HOME = "%JAVA_HOME%" >&2
echo Please set the JAVA_HOME variable in your environment to match the >&2
echo location of your Java installation. >&2
echo.
goto error

:chkMHome
if not "%M2_HOME%"=="" goto valMHome

SET "M2_HOME=%~dp0.."
if not "%M2_HOME%"=="" goto valMHome

echo.
echo Error: M2_HOME not found in your environment. >&2
echo Please set the M2_HOME variable in your environment to match the >&2
echo location of the BFG installation. >&2
echo.
goto error

:valMHome

:stripMHome
if not "_%M2_HOME:~-1%"=="_\" goto checkMCmd
set "M2_HOME=%M2_HOME:~0,-1%"
goto stripMHome

:checkMCmd
if exist "%M2_HOME%\bin\bfg.cmd" goto init

echo.
echo Error: M2_HOME is set to an invalid directory. >&2
echo M2_HOME = "%M2_HOME%" >&2
echo Please set the M2_HOME variable in your environment to match the >&2
echo location of the BFG installation >&2
echo.
goto error
@REM ==== END VALIDATION ====

:init

set BFG_CMD_LINE_ARGS=%*

@REM Find the project base dir, i.e. the directory that contains the folder ".mvn".
@REM Fallback to current working directory if not found.

set BFG_PROJECTBASEDIR=%BFG_BASEDIR%
IF NOT "%BFG_PROJECTBASEDIR%"=="" goto endDetectBaseDir

set EXEC_DIR=%CD%
set WDIR=%EXEC_DIR%
:findBaseDir
IF EXIST "%WDIR%"\.mvn goto baseDirFound
cd ..
IF "%WDIR%"=="%CD%" goto baseDirNotFound
set WDIR=%CD%
goto findBaseDir

:baseDirFound
set BFG_PROJECTBASEDIR=%WDIR%
cd "%EXEC_DIR%"
goto endDetectBaseDir

:baseDirNotFound
set BFG_PROJECTBASEDIR=%EXEC_DIR%
cd "%EXEC_DIR%"

:endDetectBaseDir

IF NOT EXIST "%BFG_PROJECTBASEDIR%\.mvn\jvm.config" goto endReadAdditionalConfig

@setlocal EnableExtensions EnableDelayedExpansion
for /F "usebackq delims=" %%a in ("%BFG_PROJECTBASEDIR%\.mvn\jvm.config") do set JVM_CONFIG_BFG_PROPS=!JVM_CONFIG_BFG_PROPS! %%a
@endlocal & set JVM_CONFIG_BFG_PROPS=%JVM_CONFIG_BFG_PROPS%

:endReadAdditionalConfig

SET BFG_JAVA_EXE="%JAVA_HOME%\bin\java.exe"

set BFG_JAR=%M2_HOME%\lib\bfg.jar

%BFG_JAVA_EXE% %JVM_CONFIG_BFG_PROPS% %BFG_OPTS% %BFG_DEBUG_OPTS% -jar %BFG_JAR% %BFG_CMD_LINE_ARGS%
if ERRORLEVEL 1 goto error
goto end

:error
set ERROR_CODE=1

:end
@endlocal & set ERROR_CODE=%ERROR_CODE%

if not "%BFG_SKIP_RC%" == "" goto skipRcPost
@REM check for post script, once with legacy .bat ending and once with .cmd ending
if exist "%HOME%\BFGrc_post.bat" call "%HOME%\BFGrc_post.bat"
if exist "%HOME%\BFGrc_post.cmd" call "%HOME%\BFGrc_post.cmd"
:skipRcPost

@REM pause the script if BFG_BATCH_PAUSE is set to 'on'
if "%BFG_BATCH_PAUSE%" == "on" pause

if "%BFG_TERMINATE_CMD%" == "on" exit %ERROR_CODE%

exit /B %ERROR_CODE%
