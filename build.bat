@echo off
setlocal

set ROOT=%~dp0
set SRC=%ROOT%src
set BIN=%ROOT%bin
set LIB=%ROOT%lib
set FPC=C:\Lazarus\fpc\3.2.2\bin\x86_64-win64\fpc.exe

set TESTFLAGS=
set DO_CLEAN=0
set DO_RUN=0

:parse_args
if "%1"=="" goto args_done
if "%1"=="test" set TESTFLAGS=-dRUN_TESTS
if "%1"=="clean" set DO_CLEAN=1
if "%1"=="run" set DO_RUN=1
if "%1"=="help" (
    echo Usage: build.bat [options]
    echo Options:
    echo   test   - Build with tests enabled
    echo   clean  - Clean build outputs
    echo   run    - Run the built executable after building
    echo   help   - Show this help message
    exit /b 0
)
shift
goto parse_args
:args_done

if %DO_CLEAN%==1 (
    echo Cleaning build outputs...
    if exist "%BIN%" rd /s /q "%BIN%"
    if exist "%LIB%" rd /s /q "%LIB%"
    echo Clean complete.
    if "%TESTFLAGS%"=="" if %DO_RUN%==0 exit /b 0
)

if not exist "%BIN%" mkdir "%BIN%"
if not exist "%LIB%" mkdir "%LIB%"

REM ── Lint ────────────────────────────────────────────────────────────
powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%lint.ps1" -SrcRoot "%SRC%"
if %ERRORLEVEL% NEQ 0 exit /b 1

REM ── Build ────────────────────────────────────────────────────────────
"%FPC%" ^
  %TESTFLAGS% ^
  -FE"%BIN%" ^
  -FU"%LIB%" ^
  -Fu"%SRC%\emu" ^
  -Fu"%SRC%\wasm" ^
  -Fu"%SRC%\wasm\parser" ^
  -Fu"%SRC%\wasm\parser\sections" ^
  -Fu"%SRC%\wasm\test" ^
  -Fu"%SRC%\wasm\test\opcodes" ^
  -Fu"%SRC%\wasm\test\parsers" ^
  -Fu"%SRC%\wasm\test\binaries" ^
  -Fu"%SRC%\wasm\test\infra" ^
  -Fu"%SRC%\wasm\types" ^
  -Fu"%SRC%\wasm\vm" ^
  -gw3 ^
  -o"%BIN%\WASURO.exe" ^
  "%SRC%\project\WASURO.lpr"

if %ERRORLEVEL% NEQ 0 (
    echo Build failed with error code %ERRORLEVEL%
    exit /b %ERRORLEVEL%
)

echo Build succeeded: %BIN%\WASURO.exe

REM ── Run ────────────────────────────────────────────────────────────
if %DO_RUN%==1 (
    echo Running WASURO...
    "%BIN%\WASURO.exe"
)