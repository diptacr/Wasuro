# build.ps1 — Build script for the WASURO project
param(
    [switch]$Test,
    [switch]$Clean,
    [switch]$Run,
    [switch]$Help,
    [switch]$Debug,
    [switch]$E2E
)

# Also accept positional string args (e.g. .\build.ps1 clean test run)
foreach ($a in $args) {
    switch ($a.ToLower()) {
        'test'  { $Test  = $true }
        'clean' { $Clean = $true }
        'run'   { $Run   = $true }
        'debug' { $Debug = $true }
        'help'  { $Help  = $true }
        'e2e'   { $E2E   = $true }
    }
}

if ($Help) {
    Write-Host 'Usage: .\build.ps1 [options]'
    Write-Host 'Options:'
    Write-Host '  test   - Build with tests enabled'
    Write-Host '  clean  - Clean build outputs'
    Write-Host '  run    - Run the built executable after building'
    Write-Host '  e2e    - Run end-to-end wat tests'
    Write-Host '  debug  - Build with debug info and assertions enabled'
    Write-Host '  help   - Show this help message'
    exit 0
}

$Root = $PSScriptRoot
$Src  = Join-Path $Root 'src'
$Bin  = Join-Path $Root 'bin'
$Lib  = Join-Path $Root 'lib'
$FPC  = 'C:\Lazarus\fpc\3.2.2\bin\x86_64-win64\fpc.exe'

if (($Test -and $E2E) -or ($Run -and $E2E)) {
    Write-Host 'Error: --e2e cannot be combined with --test or --run. E2E implies a run of E2E wat tests.' -ForegroundColor Red
    exit 1
}

# ── Clean ────────────────────────────────────────────────────────────
if ($Clean) {
    Write-Host 'Cleaning build outputs...'
    if (Test-Path $Bin) { Remove-Item "$Bin\*" -Recurse -Force }
    if (Test-Path $Lib) { Remove-Item "$Lib\*" -Recurse -Force }
    Write-Host 'Clean complete.'
}

if (-not (Test-Path $Bin)) { New-Item $Bin -ItemType Directory | Out-Null }
if (-not (Test-Path $Lib)) { New-Item $Lib -ItemType Directory | Out-Null }

# ── Lint ─────────────────────────────────────────────────────────────
& (Join-Path $Root 'lint.ps1') -SrcRoot $Src
if ($LASTEXITCODE -ne 0) { exit 1 }

# ── Build ────────────────────────────────────────────────────────────
$TestFlags = @()
if ($Test)  { $TestFlags += '-dRUN_TESTS' }
if ($Debug) { $TestFlags += '-dDEBUG_OUTPUT' }

$fpcArgs = @(
    $TestFlags
    "-v0ew"
    "-FE$Bin"
    "-FU$Lib"
    "-Fu$Src\emu"
    "-Fu$Src\wasm"
    "-Fu$Src\wasm\parser"
    "-Fu$Src\wasm\parser\sections"
    "-Fu$Src\wasm\test"
    "-Fu$Src\wasm\test\opcodes"
    "-Fu$Src\wasm\test\parsers"
    "-Fu$Src\wasm\test\binaries"
    "-Fu$Src\wasm\test\infra"
    "-Fu$Src\wasm\types"
    "-Fu$Src\wasm\vm"
    "-Fu$Src\wasm\vm\opcodes"
    "-Fu$Src\wasm\wasi"
    "-Fu$Src\wasm\wasi\preview1"
    "-Fu$Src\wasm\test\wasi"
    '-gw3'
    "-o$Bin\WASURO.exe"
    "$Src\project\WASURO.lpr"
)

& $FPC @fpcArgs
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed with error code $LASTEXITCODE"
    exit $LASTEXITCODE
}

Write-Host "Build succeeded: $Bin\WASURO.exe"

# ── Run ──────────────────────────────────────────────────────────────
if ($Run) {
    Write-Host 'Running WASURO...'
    & "$Bin\WASURO.exe"
}

if ($E2E) {
    Write-Host 'Running end-to-end WAT tests...'
    & (Join-Path $Root 'wat.ps1')
    if ($LASTEXITCODE -ne 0) {
        Write-Host "WAT tests failed with error code $LASTEXITCODE"
        exit $LASTEXITCODE
    }
    exit $LASTEXITCODE
}