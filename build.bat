@echo off
setlocal

set ROOT=%~dp0
set SRC=%ROOT%src
set BIN=%ROOT%bin
set LIB=%ROOT%lib
set FPC=C:\Lazarus\fpc\3.2.2\bin\x86_64-win64\fpc.exe

set TESTFLAGS=
if "%1"=="test" set TESTFLAGS=-dRUN_TESTS

if not exist "%BIN%" mkdir "%BIN%"
if not exist "%LIB%" mkdir "%LIB%"

REM ── Lint ────────────────────────────────────────────────────────────
powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%lint.ps1" -SrcRoot "%SRC%"
if %ERRORLEVEL% NEQ 0 exit /b 1

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
