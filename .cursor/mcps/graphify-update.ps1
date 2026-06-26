$ErrorActionPreference = "Stop"

$graphify = Join-Path $env:USERPROFILE ".local\bin\graphify.exe"
if (-not (Test-Path $graphify)) {
    $graphify = (Get-Command graphify -ErrorAction SilentlyContinue).Source
}
if (-not $graphify) {
    Write-Error "graphify not found on PATH. Install with: uv tool install graphifyy"
}

$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
Set-Location $root
& $graphify update .
