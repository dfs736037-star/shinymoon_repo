# Ollama + ollama-mcp integration for shinymoon workflow (Windows)
param(
    [ValidateSet("7b", "14b", "3b")]
    [string]$ModelSize = "7b",
    [switch]$SkipModelPull,
    [switch]$SkipMcpMerge
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
if (-not (Test-Path (Join-Path $ProjectRoot "shinymoon_alpha.lua"))) {
    $ProjectRoot = Split-Path $PSScriptRoot -Parent
}

Set-Location $ProjectRoot
Write-Host "Project: $ProjectRoot"

$ollamaExe = "$env:LOCALAPPDATA\Programs\Ollama\ollama.exe"
if (-not (Test-Path $ollamaExe)) {
    $cmd = Get-Command ollama -ErrorAction SilentlyContinue
    if ($cmd) { $ollamaExe = $cmd.Source }
}
if (-not (Test-Path $ollamaExe)) {
    Write-Host "Ollama not found. Install from https://ollama.com/download then re-run."
    exit 1
}
Write-Host "Ollama: $ollamaExe"

# Cursor needs CORS when calling localhost from the client (Chat override)
[System.Environment]::SetEnvironmentVariable("OLLAMA_ORIGINS", "*", "User")
$env:OLLAMA_ORIGINS = "*"
Write-Host "Set OLLAMA_ORIGINS=* (User env)"

function Test-OllamaRunning {
    try {
        Invoke-RestMethod -Uri "http://127.0.0.1:11434/api/tags" -TimeoutSec 3 | Out-Null
        return $true
    } catch {
        return $false
    }
}

if (-not (Test-OllamaRunning)) {
    Write-Host "Starting Ollama..."
    Start-Process -FilePath $ollamaExe -ArgumentList "serve" -WindowStyle Hidden
    $deadline = (Get-Date).AddSeconds(20)
    while ((Get-Date) -lt $deadline) {
        if (Test-OllamaRunning) { break }
        Start-Sleep -Seconds 1
    }
    if (-not (Test-OllamaRunning)) {
        Write-Error "Ollama did not start on http://127.0.0.1:11434. Open the Ollama app manually and re-run."
    }
}
Write-Host "Ollama API: OK"

$model = "qwen2.5-coder:$ModelSize"
if (-not $SkipModelPull) {
    Write-Host "Pulling $model (first run may take several minutes)..."
    & $ollamaExe pull $model
    if ($LASTEXITCODE -ne 0) { Write-Warning "Model pull failed; run manually: ollama pull $model" }
    else { Write-Host "Model ready: $model" }
}

if (-not $SkipMcpMerge) {
    $mcpMain = Join-Path $ProjectRoot ".cursor\mcp.json"
    $mcpOllama = Join-Path $ProjectRoot ".cursor\mcp.ollama.json"
    if (-not (Test-Path $mcpMain)) { Write-Error "Missing $mcpMain" }
    if (-not (Test-Path $mcpOllama)) { Write-Error "Missing $mcpOllama" }

    $main = Get-Content $mcpMain -Raw | ConvertFrom-Json
    $frag = Get-Content $mcpOllama -Raw | ConvertFrom-Json
    foreach ($prop in $frag.mcpServers.PSObject.Properties) {
        $name = $prop.Name
        $main.mcpServers | Add-Member -NotePropertyName $name -NotePropertyValue $prop.Value -Force
        Write-Host "Merged MCP: $name"
    }
    $main | ConvertTo-Json -Depth 10 | Set-Content $mcpMain -Encoding UTF8
    Write-Host "Updated $mcpMain"
}

Write-Host ""
Write-Host "Done."
Write-Host "  1. Restart Cursor (Settings -> MCP -> reload)"
Write-Host "  2. Read guide: .cursor/setup/OLLAMA_INTEGRATION.md"
Write-Host "  3. Optional Chat override: Base URL http://127.0.0.1:11434/v1, model $model"
