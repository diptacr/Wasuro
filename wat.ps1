<#
.SYNOPSIS
    Compile all .wat files under wat\ to .wasm in bin\, then run each
    through WASURO.exe and assert the expected output.

.DESCRIPTION
    Assertion metadata is embedded in the .wat source as comments:
        ;; @expect-exit <code>
        ;; @expect-stdout <text>
    Multiple @expect-stdout lines are joined with newlines.
    If no @expect-exit is specified, exit code 0 is assumed.

.EXAMPLE
    .\wat.ps1
    .\wat.ps1 -Verbose
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Continue'
$Root   = Split-Path -Parent $MyInvocation.MyCommand.Path
$WatDir = Join-Path $Root 'wat'
$BinDir = Join-Path $Root 'bin'
$Exe    = Join-Path $BinDir 'WASURO.exe'

# ---------- pre-flight checks ----------

if (-not (Get-Command 'wat2wasm' -ErrorAction SilentlyContinue)) {
    Write-Host 'Error: wat2wasm not found in PATH. Install wabt first.' -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $Exe)) {
    Write-Host "Error: $Exe not found. Run .\build.ps1 first." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $WatDir)) {
    Write-Host "Error: $WatDir directory not found." -ForegroundColor Red
    exit 1
}

# ---------- helpers ----------

function Parse-Expectations {
    param([string]$WatPath)

    $exit   = 0
    $stdout = @()

    foreach ($line in (Get-Content $WatPath)) {
        if ($line -match '^\s*;;\s*@expect-exit\s+(\d+)') {
            $exit = [int]$Matches[1]
        }
        elseif ($line -match '^\s*;;\s*@expect-stdout\s+(.*)$') {
            $stdout += $Matches[1]
        }
    }

    return @{
        ExitCode = $exit
        Stdout   = ($stdout -join "`n")
    }
}

# ---------- main ----------

$watFiles = Get-ChildItem -Path $WatDir -Recurse -Filter '*.wat'

if ($watFiles.Count -eq 0) {
    Write-Host 'No .wat files found.' -ForegroundColor Yellow
    exit 0
}

Write-Host '========================================' -ForegroundColor Cyan
Write-Host '  WASURO WAT Test Runner' -ForegroundColor Cyan
Write-Host '========================================' -ForegroundColor Cyan
Write-Host ''

$total  = 0
$passed = 0
$failed = 0

foreach ($wat in $watFiles) {
    $total++

    $wasmName = [System.IO.Path]::ChangeExtension($wat.Name, '.wasm')
    $wasmPath = Join-Path $BinDir $wasmName
    $relPath  = $wat.FullName.Substring($Root.Length + 1)

    # ---- compile ----
    Write-Verbose "Compiling $relPath -> bin\$wasmName"
    $compileOutput = cmd /c "wat2wasm `"$($wat.FullName)`" -o `"$wasmPath`" 2>&1"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  FAIL: $relPath  (wat2wasm failed)" -ForegroundColor Red
        if ($compileOutput) { Write-Host "        $compileOutput" -ForegroundColor DarkRed }
        $failed++
        continue
    }

    # ---- parse expectations ----
    $expect = Parse-Expectations $wat.FullName

    # ---- run ----
    $actualStdout = cmd /c "`"$Exe`" `"$wasmPath`" 2>nul"
    $actualExit   = $LASTEXITCODE

    # Strip the WASURO banner line from stdout for assertion
    $lines = @()
    if ($actualStdout) {
        if ($actualStdout -is [string]) {
            $lines = $actualStdout -split "`r?`n"
        } else {
            $lines = @($actualStdout | ForEach-Object { "$_" })
        }
    }
    $contentLines = @()
    foreach ($line in $lines) {
        # Skip banner and empty trailing lines
        if ($line -match '^WASURO - WebAssembly Runtime') { continue }
        if ($line -match '^Module loaded') { continue }
        $contentLines += $line
    }
    # Trim trailing empty lines
    while ($contentLines.Count -gt 0 -and $contentLines[-1] -eq '') {
        $contentLines = $contentLines[0..($contentLines.Count - 2)]
    }
    $actualContent = $contentLines -join "`n"

    # ---- assert ----
    $exitOk   = ($actualExit -eq $expect.ExitCode)
    $stdoutOk = ($actualContent -eq $expect.Stdout)

    if ($exitOk -and $stdoutOk) {
        Write-Host "  PASS: $relPath" -ForegroundColor Green
        $passed++
    }
    else {
        Write-Host "  FAIL: $relPath" -ForegroundColor Red
        if (-not $exitOk) {
            Write-Host "        exit: expected $($expect.ExitCode), got $actualExit" -ForegroundColor DarkRed
        }
        if (-not $stdoutOk) {
            Write-Host "        stdout expected: [$($expect.Stdout)]" -ForegroundColor DarkRed
            Write-Host "        stdout actual:   [$actualContent]" -ForegroundColor DarkRed
        }
        $failed++
    }
}

Write-Host ''
Write-Host '========================================' -ForegroundColor Cyan
Write-Host "  Total:  $total" -ForegroundColor Cyan
Write-Host "  Passed: $passed" -ForegroundColor Green
Write-Host "  Failed: $failed" -ForegroundColor $(if ($failed -gt 0) { 'Red' } else { 'Green' })
Write-Host '========================================' -ForegroundColor Cyan

exit $failed
