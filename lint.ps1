# lint.ps1 — Static lint rules for the WASURO project
# Called by build.bat before compilation. Exit 1 on any violation.
param(
    [string]$SrcRoot = (Join-Path $PSScriptRoot 'src')
)

$fail = $false

# ── Rule: No native types in src\wasm ────────────────────────────────
# All code under src\wasm must use TWASM* aliases from wasm.types.builtin.
# Only wasm.types.builtin.pas itself may reference the raw types.
$forbiddenTypes = @(
    'uint8','uint16','uint32','uint64',
    'sint8','sint16',
    'int32','int64',
    'float','double',
    'puint8','puint16','puint32','puint64',
    'pfloat','pdouble','pchar',
    'boolean','char','void','integer'
)
$pattern = '(?i)(?<![a-z0-9_])(' + ($forbiddenTypes -join '|') + ')(?![a-z0-9_])'

$files = Get-ChildItem (Join-Path $SrcRoot 'wasm') -Recurse -Filter '*.pas' |
    Where-Object { $_.Name -ne 'wasm.types.builtin.pas' }

$ruleHits = 0
foreach ($file in $files) {
    $content = [IO.File]::ReadAllText($file.FullName)
    $matches = [regex]::Matches($content, $pattern)
    if ($matches.Count -gt 0) {
        $found = @{}
        foreach ($m in $matches) { $found[$m.Value.ToLower()] = $true }
        $list = ($found.Keys | Sort-Object) -join ', '
        Write-Host "  $($file.Name): $list"
        $ruleHits++
    }
}

if ($ruleHits -gt 0) {
    Write-Host ''
    Write-Host "Lint failed: $ruleHits file(s) use native types. Use TWASM* from wasm.types.builtin instead."
    $fail = $true
}

# ── Add more rules here ─────────────────────────────────────────────

if ($fail) { exit 1 }
Write-Host 'Lint passed.'
