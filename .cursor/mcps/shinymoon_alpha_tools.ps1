$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$ServerName = "shinymoon-alpha-tools"
$ServerVersion = "0.2.0"
$NeverloseDocsBase = "https://docs-csgo.neverlose.cc/"
$UseHeaders = $false

$Workspace = $env:SHINYMOON_WORKSPACE
if ([string]::IsNullOrWhiteSpace($Workspace)) {
    $Workspace = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
}
$Workspace = [System.IO.Path]::GetFullPath($Workspace)
$DataDir = Join-Path $Workspace ".cursor\mcp-data"
$MemoryFile = Join-Path $DataDir "memory_notes.jsonl"
$TestLogFile = Join-Path $DataDir "test_logs.jsonl"
$InputStream = [Console]::OpenStandardInput()
$OutputStream = [Console]::OpenStandardOutput()

function Ensure-DataDir {
    if (-not (Test-Path -LiteralPath $DataDir)) {
        New-Item -ItemType Directory -Force -Path $DataDir | Out-Null
    }
}

function Resolve-WorkspacePath {
    param([string]$Path)
    $full = [System.IO.Path]::GetFullPath((Join-Path $Workspace $Path))
    if (-not $full.StartsWith($Workspace, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Path is outside the workspace"
    }
    return $full
}

function ConvertFrom-HtmlText {
    param([string]$Html)
    $text = [regex]::Replace($Html, "(?is)<(script|style).*?>.*?</\1>", " ")
    $text = [regex]::Replace($text, "(?s)<[^>]+>", " ")
    $text = [System.Net.WebUtility]::HtmlDecode($text)
    $text = [regex]::Replace($text, "[`t ]+", " ")
    $text = [regex]::Replace($text, "(`r?`n)\s*(`r?`n)+", "`n`n")
    return $text.Trim()
}

function New-TextContent {
    param([string]$Text, [bool]$IsError = $false)
    return @{
        content = @(@{ type = "text"; text = $Text })
        isError = $IsError
    }
}

function Invoke-FetchNeverloseDoc {
    param($Arguments)
    $raw = ""
    if ($Arguments -and $Arguments.path_or_url) { $raw = [string]$Arguments.path_or_url }
    if ([string]::IsNullOrWhiteSpace($raw)) { $raw = $NeverloseDocsBase }

    if ($raw -match "^https?://") {
        $uri = [Uri]$raw
    } else {
        $uri = [Uri]::new([Uri]$NeverloseDocsBase, $raw.TrimStart("/"))
    }

    if ($uri.Host -ne "docs-csgo.neverlose.cc") {
        throw "Only docs-csgo.neverlose.cc URLs are allowed"
    }

    $response = Invoke-WebRequest -Uri $uri.AbsoluteUri -UseBasicParsing -Headers @{ "User-Agent" = "$ServerName/$ServerVersion Cursor MCP" }
    $text = ConvertFrom-HtmlText ([string]$response.Content)
    if ($text.Length -gt 20000) {
        $text = $text.Substring(0, 20000) + "`n`n[truncated]"
    }
    return "Source: $($uri.AbsoluteUri)`n`n$text"
}

function Invoke-NeverloseDocLinks {
    param($Arguments)
    $query = ""
    $limit = 30
    if ($Arguments) {
        if ($Arguments.query) { $query = ([string]$Arguments.query).ToLowerInvariant() }
        if ($Arguments.limit) { $limit = [int]$Arguments.limit }
    }

    $response = Invoke-WebRequest -Uri $NeverloseDocsBase -UseBasicParsing -Headers @{ "User-Agent" = "$ServerName/$ServerVersion Cursor MCP" }
    $matches = [regex]::Matches([string]$response.Content, 'href=["'']([^"'']+)["''][^>]*>(.*?)</a>', "IgnoreCase,Singleline")
    $lines = New-Object System.Collections.Generic.List[string]

    foreach ($match in $matches) {
        $label = ConvertFrom-HtmlText $match.Groups[2].Value
        if ([string]::IsNullOrWhiteSpace($label)) { continue }
        $url = ([Uri]::new([Uri]$NeverloseDocsBase, $match.Groups[1].Value)).AbsoluteUri
        if (([Uri]$url).Host -ne "docs-csgo.neverlose.cc") { continue }
        $combined = "$label $url".ToLowerInvariant()
        if ($query -and -not $combined.Contains($query)) { continue }
        $lines.Add("- $label`: $url")
        if ($lines.Count -ge $limit) { break }
    }

    if ($lines.Count -eq 0) { return "No matching Neverlose documentation links found." }
    return ($lines -join "`n")
}

function Get-ProjectFiles {
    param([string]$Glob = "*")
    Get-ChildItem -LiteralPath $Workspace -Recurse -File -Force |
        Where-Object {
            $relative = [System.IO.Path]::GetRelativePath($Workspace, $_.FullName).Replace("\", "/")
            -not $relative.StartsWith(".git/") -and
            -not $relative.StartsWith(".cursor/mcp-data/") -and
            ($_.Name -like $Glob -or $relative -like $Glob -or $Glob -eq "**/*")
        }
}

function Invoke-ListLuaScripts {
    param($Arguments)
    $limit = 50
    if ($Arguments -and $Arguments.limit) { $limit = [int]$Arguments.limit }
    $files = Get-ProjectFiles "*.lua" |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First $limit

    $lines = foreach ($file in $files) {
        $relative = [System.IO.Path]::GetRelativePath($Workspace, $file.FullName)
        "- $relative ($($file.Length) bytes)"
    }
    return ($lines -join "`n")
}

function Invoke-ReadProjectFile {
    param($Arguments)
    if (-not $Arguments -or -not $Arguments.path) { throw "Missing path" }
    $path = Resolve-WorkspacePath ([string]$Arguments.path)
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "File not found" }
    $maxChars = 30000
    if ($Arguments.max_chars) { $maxChars = [int]$Arguments.max_chars }
    $text = Get-Content -LiteralPath $path -Raw -Encoding UTF8
    if ($text.Length -gt $maxChars) {
        $text = $text.Substring(0, $maxChars) + "`n`n[truncated]"
    }
    return $text
}

function Invoke-SearchProject {
    param($Arguments)
    if (-not $Arguments -or -not $Arguments.pattern) { throw "Missing pattern" }
    $pattern = [string]$Arguments.pattern
    $glob = "**/*"
    $maxResults = 100
    if ($Arguments.glob) { $glob = [string]$Arguments.glob }
    if ($Arguments.max_results) { $maxResults = [int]$Arguments.max_results }
    $caseSensitive = $false
    if ($Arguments.case_sensitive) { $caseSensitive = [bool]$Arguments.case_sensitive }

    $options = [System.Text.RegularExpressions.RegexOptions]::None
    if (-not $caseSensitive) { $options = $options -bor [System.Text.RegularExpressions.RegexOptions]::IgnoreCase }
    $regex = [regex]::new($pattern, $options)
    $results = New-Object System.Collections.Generic.List[string]

    foreach ($file in (Get-ProjectFiles $glob)) {
        if ($file.Length -gt 1500000) { continue }
        $relative = [System.IO.Path]::GetRelativePath($Workspace, $file.FullName).Replace("\", "/")
        try {
            $lines = Get-Content -LiteralPath $file.FullName -Encoding UTF8
        } catch {
            continue
        }
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($regex.IsMatch([string]$lines[$i])) {
                $results.Add("$relative`:$($i + 1): $(([string]$lines[$i]).Trim())")
                if ($results.Count -ge $maxResults) { return ($results -join "`n") }
            }
        }
    }

    if ($results.Count -eq 0) { return "No matches found." }
    return ($results -join "`n")
}

function Invoke-MemoryAdd {
    param($Arguments)
    Ensure-DataDir
    if (-not $Arguments -or -not $Arguments.title -or -not $Arguments.content) {
        throw "Missing title or content"
    }
    $tags = @()
    if ($Arguments.tags) {
        if ($Arguments.tags -is [array]) { $tags = $Arguments.tags }
        else { $tags = ([string]$Arguments.tags).Split(",") | ForEach-Object { $_.Trim() } | Where-Object { $_ } }
    }
    $entry = [ordered]@{
        id = [string][DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
        created_at = [DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
        title = [string]$Arguments.title
        content = [string]$Arguments.content
        tags = @($tags)
    }
    ($entry | ConvertTo-Json -Compress -Depth 8) | Add-Content -LiteralPath $MemoryFile -Encoding UTF8
    return "Saved memory note $($entry.id): $($entry.title)"
}

function Invoke-MemorySearch {
    param($Arguments)
    Ensure-DataDir
    $query = ""
    $limit = 20
    if ($Arguments) {
        if ($Arguments.query) { $query = ([string]$Arguments.query).ToLowerInvariant() }
        if ($Arguments.limit) { $limit = [int]$Arguments.limit }
    }
    if (-not (Test-Path -LiteralPath $MemoryFile)) { return "No memory notes found." }
    $entries = Get-Content -LiteralPath $MemoryFile -Encoding UTF8 | Where-Object { $_ }
    if ($query) {
        $entries = $entries | Where-Object { $_.ToLowerInvariant().Contains($query) }
    }
    $entries = @($entries | Select-Object -Last $limit)
    if ($entries.Count -eq 0) { return "No memory notes found." }

    $lines = foreach ($line in $entries) {
        $entry = $line | ConvertFrom-Json
        "$($entry.id) | $($entry.created_at) | $($entry.title)`ntags: $($entry.tags -join ', ')`n$($entry.content)"
    }
    return ($lines -join "`n`n")
}

function Invoke-AddTestLog {
    param($Arguments)
    Ensure-DataDir
    $entry = [ordered]@{
        id = [string][DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
        created_at = [DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
        feature = if ($Arguments.feature) { [string]$Arguments.feature } else { $null }
        map_name = if ($Arguments.map_name) { [string]$Arguments.map_name } else { $null }
        config = if ($Arguments.config) { [string]$Arguments.config } else { $null }
        result = if ($Arguments.result) { [string]$Arguments.result } else { $null }
        notes = if ($Arguments.notes) { [string]$Arguments.notes } else { $null }
    }
    ($entry | ConvertTo-Json -Compress -Depth 8) | Add-Content -LiteralPath $TestLogFile -Encoding UTF8
    return "Saved test log $($entry.id)"
}

function Invoke-ReadTestLogs {
    param($Arguments)
    Ensure-DataDir
    $limit = 20
    $query = ""
    if ($Arguments) {
        if ($Arguments.limit) { $limit = [int]$Arguments.limit }
        if ($Arguments.query) { $query = ([string]$Arguments.query).ToLowerInvariant() }
    }
    if (-not (Test-Path -LiteralPath $TestLogFile)) { return "No test logs found." }
    $entries = Get-Content -LiteralPath $TestLogFile -Encoding UTF8 | Where-Object { $_ }
    if ($query) {
        $entries = $entries | Where-Object { $_.ToLowerInvariant().Contains($query) }
    }
    $entries = @($entries | Select-Object -Last $limit)
    if ($entries.Count -eq 0) { return "No test logs found." }
    return ($entries -join "`n")
}

function Invoke-AppleUiPrinciples {
    param($Arguments)
    $target = "Neverlose Lua UI"
    if ($Arguments -and $Arguments.target) { $target = [string]$Arguments.target }

    return @"
Apple-style UI direction for $target

Principles:
- Clarity first: short labels, obvious hierarchy, no clever names for critical controls.
- Deference: the UI should support the script features without becoming visually noisy.
- Depth: use grouping, spacing, subtle separators, and progressive disclosure instead of heavy borders.
- Consistency: repeat the same label rhythm, casing, spacing, and control order across sections.
- Calm defaults: avoid aggressive colors except for state, warnings, or destructive actions.

For Neverlose/Lua menus:
- Prefer compact sections with 3-7 related controls per group.
- Put enable toggles first, then mode selectors, then fine tuning sliders.
- Use descriptions/tooltips for risky or non-obvious HVH behavior.
- Keep color accents sparse: one primary accent, one warning color, one disabled/secondary tone.
- Avoid dumping experimental features into the main path; place them under Advanced or Debug.
"@
}

function Invoke-AppleUiPalette {
    param($Arguments)
    $accent = "blue"
    if ($Arguments -and $Arguments.accent) { $accent = ([string]$Arguments.accent).ToLowerInvariant() }

    $accents = @{
        blue = @{ primary = "#0A84FF"; hover = "#409CFF"; soft = "#E5F1FF" }
        purple = @{ primary = "#BF5AF2"; hover = "#CC7AF5"; soft = "#F6EAFE" }
        green = @{ primary = "#30D158"; hover = "#55DA76"; soft = "#E8FBEF" }
        orange = @{ primary = "#FF9F0A"; hover = "#FFB340"; soft = "#FFF4E0" }
        red = @{ primary = "#FF453A"; hover = "#FF6961"; soft = "#FFE9E7" }
    }
    if (-not $accents.ContainsKey($accent)) { $accent = "blue" }
    $selected = $accents[$accent]

    return @"
Apple-inspired palette ($accent accent)

Dark surface:
- Background: #0B0B0F
- Elevated panel: #15151C
- Secondary panel: #1C1C24
- Hairline separator: #2C2C35
- Primary text: #F5F5F7
- Secondary text: #A1A1AA
- Disabled text: #5F5F6B

Accent:
- Primary: $($selected.primary)
- Hover/active: $($selected.hover)
- Soft tint: $($selected.soft)

Semantic:
- Success: #30D158
- Warning: #FFD60A
- Danger: #FF453A
- Info: #64D2FF

Usage:
- Use the accent only for selected states, primary toggles, and key status indicators.
- Use separators at low opacity; avoid thick outlines.
- Prefer rounded panels and small spacing increments: 4, 8, 12, 16, 24.
"@
}

function Invoke-AppleUiComponentSpec {
    param($Arguments)
    $component = "settings panel"
    $purpose = "configure script behavior"
    if ($Arguments) {
        if ($Arguments.component) { $component = [string]$Arguments.component }
        if ($Arguments.purpose) { $purpose = [string]$Arguments.purpose }
    }

    return @"
Component spec: $component

Purpose:
- $purpose

Structure:
- Header: concise title plus optional one-line description.
- Primary control: enable/disable or main mode selector.
- Configuration group: related sliders, combos, hotkeys, or color pickers.
- Status row: current active state, warnings, or dependency hints.
- Advanced disclosure: hide risky/rarely used controls behind an Advanced section.

Apple-style details:
- Label length: 1-3 words where possible.
- Descriptions: sentence case, practical, no hype.
- Alignment: labels left, values/control affordances right.
- Spacing: 12px between rows, 16-24px between groups.
- Visual weight: one highlighted action per panel.

Neverlose Lua mapping:
- Use UI groups/tabs to mirror feature ownership.
- Keep toggles above sliders.
- Use color pickers only where the color is visible in-game.
- Add dependency hints when a control only works with another toggle or mode.
"@
}

function Invoke-AppleUiReviewChecklist {
    param($Arguments)
    $notes = ""
    if ($Arguments -and $Arguments.notes) { $notes = [string]$Arguments.notes }

    $result = @"
Apple-style UI review checklist

Check:
- Can a new user understand the first action in each section?
- Are labels short, literal, and consistent?
- Are dangerous/experimental controls separated from normal controls?
- Is there one clear accent color and one clear warning color?
- Are related controls grouped by behavior, not implementation detail?
- Are sliders named by outcome instead of internal math?
- Are inactive/dependent controls explained or hidden?
- Is the menu calm at a glance, with no unnecessary color noise?

Recommended section order for shinymoon_alpha:
- Main
- Anti-Aim
- Defensive
- Visuals
- Misc
- Presets
- Debug / Advanced
"@

    if (-not [string]::IsNullOrWhiteSpace($notes)) {
        $result += "`nNotes to review:`n$notes"
    }
    return $result
}

$Tools = @{
    fetch_neverlose_doc = @{
        description = "Fetch and simplify a page from the official Neverlose CS:GO documentation."
        inputSchema = @{
            type = "object"
            properties = @{
                path_or_url = @{ type = "string"; description = "Docs path or full docs-csgo.neverlose.cc URL." }
            }
        }
        handler = ${function:Invoke-FetchNeverloseDoc}
    }
    neverlose_doc_links = @{
        description = "List links discovered from the Neverlose documentation home page, optionally filtered by query."
        inputSchema = @{
            type = "object"
            properties = @{
                query = @{ type = "string" }
                limit = @{ type = "integer"; default = 30 }
            }
        }
        handler = ${function:Invoke-NeverloseDocLinks}
    }
    list_lua_scripts = @{
        description = "List Lua scripts in the shinymoon workspace."
        inputSchema = @{
            type = "object"
            properties = @{ limit = @{ type = "integer"; default = 50 } }
        }
        handler = ${function:Invoke-ListLuaScripts}
    }
    read_project_file = @{
        description = "Read a text file from the shinymoon workspace."
        inputSchema = @{
            type = "object"
            required = @("path")
            properties = @{
                path = @{ type = "string" }
                max_chars = @{ type = "integer"; default = 30000 }
            }
        }
        handler = ${function:Invoke-ReadProjectFile}
    }
    search_project = @{
        description = "Regex search over workspace files, useful for Lua APIs, netvars, UI names, and old script references."
        inputSchema = @{
            type = "object"
            required = @("pattern")
            properties = @{
                pattern = @{ type = "string" }
                glob = @{ type = "string"; default = "**/*" }
                case_sensitive = @{ type = "boolean"; default = $false }
                max_results = @{ type = "integer"; default = 100 }
            }
        }
        handler = ${function:Invoke-SearchProject}
    }
    memory_add = @{
        description = "Save a project note, decision, bug, preset idea, or testing observation."
        inputSchema = @{
            type = "object"
            required = @("title", "content")
            properties = @{
                title = @{ type = "string" }
                content = @{ type = "string" }
                tags = @{ type = "array"; items = @{ type = "string" } }
            }
        }
        handler = ${function:Invoke-MemoryAdd}
    }
    memory_search = @{
        description = "Search saved shinymoon project notes."
        inputSchema = @{
            type = "object"
            properties = @{
                query = @{ type = "string" }
                limit = @{ type = "integer"; default = 20 }
            }
        }
        handler = ${function:Invoke-MemorySearch}
    }
    add_test_log = @{
        description = "Store a structured local test log."
        inputSchema = @{
            type = "object"
            properties = @{
                feature = @{ type = "string" }
                map_name = @{ type = "string" }
                config = @{ type = "string" }
                result = @{ type = "string" }
                notes = @{ type = "string" }
            }
        }
        handler = ${function:Invoke-AddTestLog}
    }
    read_test_logs = @{
        description = "Read saved local test logs."
        inputSchema = @{
            type = "object"
            properties = @{
                query = @{ type = "string" }
                limit = @{ type = "integer"; default = 20 }
            }
        }
        handler = ${function:Invoke-ReadTestLogs}
    }
    apple_ui_principles = @{
        description = "Return Apple-style UI principles adapted for Neverlose Lua menus."
        inputSchema = @{
            type = "object"
            properties = @{
                target = @{ type = "string"; default = "Neverlose Lua UI" }
            }
        }
        handler = ${function:Invoke-AppleUiPrinciples}
    }
    apple_ui_palette = @{
        description = "Generate an Apple-inspired color palette for dark script UI design."
        inputSchema = @{
            type = "object"
            properties = @{
                accent = @{ type = "string"; description = "blue, purple, green, orange, or red"; default = "blue" }
            }
        }
        handler = ${function:Invoke-AppleUiPalette}
    }
    apple_ui_component_spec = @{
        description = "Generate a concise Apple-style UI component spec for a script menu element."
        inputSchema = @{
            type = "object"
            properties = @{
                component = @{ type = "string"; default = "settings panel" }
                purpose = @{ type = "string"; default = "configure script behavior" }
            }
        }
        handler = ${function:Invoke-AppleUiComponentSpec}
    }
    apple_ui_review_checklist = @{
        description = "Return a checklist for reviewing a UI against Apple-style clarity and hierarchy."
        inputSchema = @{
            type = "object"
            properties = @{
                notes = @{ type = "string"; description = "Optional UI notes or draft structure to review." }
            }
        }
        handler = ${function:Invoke-AppleUiReviewChecklist}
    }
}

function Get-ToolDefinitions {
    $definitions = @()
    foreach ($name in $Tools.Keys) {
        $definitions += @{
            name = $name
            description = $Tools[$name]["description"]
            inputSchema = $Tools[$name]["inputSchema"]
        }
    }
    return $definitions
}

function New-Response {
    param($Id, $Result, $ErrorObject)
    $response = [ordered]@{ jsonrpc = "2.0"; id = $Id }
    if ($ErrorObject) { $response.error = $ErrorObject }
    else { $response.result = $Result }
    return $response
}

function Read-McpMessage {
    $first = [Console]::In.ReadLine()
    if ($null -eq $first) { return $null }
    if ([string]::IsNullOrWhiteSpace($first)) { return (Read-McpMessage) }

    if ($first.ToLowerInvariant().StartsWith("content-length:")) {
        $script:UseHeaders = $true
        $length = [int]($first.Split(":", 2)[1].Trim())
        while ($true) {
            $line = [Console]::In.ReadLine()
            if ($null -eq $line -or $line -eq "") { break }
        }
        $buffer = New-Object char[] $length
        $read = 0
        while ($read -lt $length) {
            $count = [Console]::In.Read($buffer, $read, $length - $read)
            if ($count -le 0) { break }
            $read += $count
        }
        return (($buffer -join "") | ConvertFrom-Json)
    }

    return ($first | ConvertFrom-Json)
}

function Write-McpMessage {
    param($Message)
    $json = $Message | ConvertTo-Json -Compress -Depth 20
    if ($script:UseHeaders) {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
        $headerBytes = [System.Text.Encoding]::ASCII.GetBytes("Content-Length: $($bytes.Length)`r`n`r`n")
        $script:OutputStream.Write($headerBytes, 0, $headerBytes.Length)
        $script:OutputStream.Write($bytes, 0, $bytes.Length)
        $script:OutputStream.Flush()
    } else {
        [Console]::Out.WriteLine($json)
        [Console]::Out.Flush()
    }
}

function Handle-Request {
    param($Message)
    $method = [string]$Message.method
    $id = $Message.id
    $params = $Message.params

    try {
        switch ($method) {
            "initialize" {
                return New-Response $id @{
                    protocolVersion = "2024-11-05"
                    capabilities = @{ tools = @{} }
                    serverInfo = @{ name = $ServerName; version = $ServerVersion }
                } $null
            }
            "ping" {
                return New-Response $id @{} $null
            }
            "tools/list" {
                return New-Response $id @{ tools = @(Get-ToolDefinitions) } $null
            }
            "tools/call" {
                $name = [string]$params.name
                if (-not $Tools.ContainsKey($name)) { throw "Unknown tool: $name" }
                $arguments = $params.arguments
                $handler = $Tools[$name]["handler"]
                $text = & $handler $arguments
                return New-Response $id (New-TextContent $text $false) $null
            }
            "resources/list" {
                return New-Response $id @{ resources = @() } $null
            }
            "prompts/list" {
                return New-Response $id @{ prompts = @() } $null
            }
            default {
                return New-Response $id $null @{ code = -32601; message = "Method not found: $method" }
            }
        }
    } catch {
        return New-Response $id $null @{
            code = -32000
            message = $_.Exception.Message
            data = $_.ScriptStackTrace
        }
    }
}

Ensure-DataDir
while ($true) {
    $message = Read-McpMessage
    if ($null -eq $message) { break }
    if (-not ($message.PSObject.Properties.Name -contains "id")) { continue }
    $response = Handle-Request $message
    if ($null -ne $response) { Write-McpMessage $response }
}
