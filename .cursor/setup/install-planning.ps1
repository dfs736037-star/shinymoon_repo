# Install optional planning MCPs + OpenSpec CLI (requires Node.js)
param(
    [switch]$SkipNodeInstall
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
if (-not (Test-Path (Join-Path $ProjectRoot "shinymoon_alpha.lua"))) {
    $ProjectRoot = Split-Path $PSScriptRoot -Parent
}

Set-Location $ProjectRoot
Write-Host "Project: $ProjectRoot"

function Test-Node {
    $node = Get-Command node -ErrorAction SilentlyContinue
    if ($node) { return $true }
    if (Test-Path "$env:ProgramFiles\nodejs\node.exe") { return $true }
    return $false
}

if (-not (Test-Node)) {
    if ($SkipNodeInstall) {
        Write-Error "Node.js not found. Install from https://nodejs.org or run without -SkipNodeInstall"
    }
    Write-Host "Installing Node.js LTS via winget..."
    winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
    $env:Path = "$env:ProgramFiles\nodejs;" + $env:Path
}

$nodeExe = (Get-Command node -ErrorAction SilentlyContinue).Source
if (-not $nodeExe) { $nodeExe = "$env:ProgramFiles\nodejs\node.exe" }
if (-not (Test-Path $nodeExe)) {
    Write-Error "Node.js still not found after install. Restart terminal and re-run."
}
Write-Host "Node: & $nodeExe -v"

Write-Host "Installing OpenSpec CLI..."
npm install -g @fission-ai/openspec@latest
$env:Path = "$env:ProgramFiles\nodejs;$(Join-Path $env:APPDATA 'npm');" + $env:Path
if ($LASTEXITCODE -ne 0) { Write-Warning "OpenSpec global install failed; continuing with MCP merge only." }
else {
    Write-Host "Syncing OpenSpec templates (cursor)..."
    openspec update . 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "openspec update skipped (manual scaffold already present)."
    }
}

$mcpMain = Join-Path $ProjectRoot ".cursor\mcp.json"
$mcpPlanning = Join-Path $ProjectRoot ".cursor\mcp.planning.json"
if (-not (Test-Path $mcpMain)) { Write-Error "Missing $mcpMain" }
if (-not (Test-Path $mcpPlanning)) { Write-Error "Missing $mcpPlanning" }

$main = Get-Content $mcpMain -Raw | ConvertFrom-Json
$plan = Get-Content $mcpPlanning -Raw | ConvertFrom-Json
foreach ($prop in $plan.mcpServers.PSObject.Properties) {
    $name = $prop.Name
    if (-not $main.mcpServers.$name) {
        $main.mcpServers | Add-Member -NotePropertyName $name -NotePropertyValue $prop.Value
        Write-Host "Merged MCP: $name"
    } else {
        Write-Host "MCP already present: $name"
    }
}
$main | ConvertTo-Json -Depth 10 | Set-Content $mcpMain -Encoding UTF8
Write-Host "Updated $mcpMain"

Write-Host ""
Write-Host "Done. Restart Cursor to load MCPs and slash commands."
Write-Host "Docs: .cursor/setup/PLANNING_SETUP.md"
