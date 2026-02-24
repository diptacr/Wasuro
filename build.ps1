# build.ps1 — Build script for the WASURO project
param(
    [switch]$Test,
    [switch]$Clean,
    [switch]$Run,
    [switch]$Help
)

# Also accept positional string args (e.g. .\build.ps1 clean test run)
foreach ($a in $args) {
    switch ($a.ToLower()) {
        'test'  { $Test  = $true }
        'clean' { $Clean = $true }
        'run'   { $Run   = $true }
        'help'  { $Help  = $true }
    }
}

if ($Help) {
    Write-Host 'Usage: .\build.ps1 [options]'
    Write-Host 'Options:'
    Write-Host '  test   - Build with tests enabled'
    Write-Host '  clean  - Clean build outputs'
    Write-Host '  run    - Run the built executable after building'
    Write-Host '  help   - Show this help message'
    exit 0
}

$Root = $PSScriptRoot
$Src  = Join-Path $Root 'src'
$Bin  = Join-Path $Root 'bin'
$Lib  = Join-Path $Root 'lib'
$FPC  = 'C:\Lazarus\fpc\3.2.2\bin\x86_64-win64\fpc.exe'

# ── Clean ────────────────────────────────────────────────────────────
if ($Clean) {
    Write-Host 'Cleaning build outputs...'
    if (Test-Path $Bin) { Remove-Item $Bin -Recurse -Force }
    if (Test-Path $Lib) { Remove-Item $Lib -Recurse -Force }
    Write-Host 'Clean complete.'
    if (-not $Test -and -not $Run) { exit 0 }
}

if (-not (Test-Path $Bin)) { New-Item $Bin -ItemType Directory | Out-Null }
if (-not (Test-Path $Lib)) { New-Item $Lib -ItemType Directory | Out-Null }

# ── Lint ─────────────────────────────────────────────────────────────
& (Join-Path $Root 'lint.ps1') -SrcRoot $Src
if ($LASTEXITCODE -ne 0) { exit 1 }

# ── Build ────────────────────────────────────────────────────────────
$TestFlags = @()
if ($Test) { $TestFlags = @('-dRUN_TESTS') }

$fpcArgs = @(
    $TestFlags
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
