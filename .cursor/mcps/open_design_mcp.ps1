$ErrorActionPreference = "Stop"

$odRoot = Join-Path $env:LOCALAPPDATA "open-design"
$exe = Join-Path $odRoot "Open Design.exe"
$cli = Join-Path $odRoot "resources\app\prebundled\daemon\daemon-cli.mjs"

if (-not (Test-Path $exe)) {
    Write-Error "Open Design not found at $odRoot. Install the portable build or run Open Design.exe once."
}

$env:ELECTRON_RUN_AS_NODE = "1"
if (-not $env:OD_DAEMON_URL) {
    $env:OD_DAEMON_URL = "http://127.0.0.1:7456"
}

& $exe $cli mcp --daemon-url $env:OD_DAEMON_URL
