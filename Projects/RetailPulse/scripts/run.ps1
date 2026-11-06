param(
    [ValidateSet('all', 'test', 'analytics', 'performance')]
    [string]$Mode = 'all'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$OutputEncoding = New-Object System.Text.UTF8Encoding($false)
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$ComposeArgs = @('compose', '--project-directory', $ProjectRoot, '-f', (Join-Path $ProjectRoot 'compose.yaml'))
$SqlFiles = switch ($Mode) {
    'all' { '01_schema'; '02_seed'; '03_views'; '05_procedures'; '06_tests'; '04_analytics'; '07_performance' }
    'test' { '06_tests' }
    'analytics' { '04_analytics' }
    'performance' { '07_performance' }
}

Get-Command docker -ErrorAction Stop | Out-Null
& docker @ComposeArgs up -d --wait --wait-timeout 120
if ($LASTEXITCODE -ne 0) { throw 'MySQL container did not become ready.' }

foreach ($SqlFile in $SqlFiles) {
    Write-Host "`n>>> $SqlFile.sql"
    $Sql = Get-Content -LiteralPath (Join-Path $ProjectRoot "sql/$SqlFile.sql") -Raw -Encoding utf8
    $Sql | & docker @ComposeArgs exec -T db sh -c 'MYSQL_PWD=$MYSQL_ROOT_PASSWORD exec mysql --user=root --default-character-set=utf8mb4 --show-warnings'
    if ($LASTEXITCODE -ne 0) { throw "Execution failed: $SqlFile.sql" }
}

Write-Host "`nRetailPulse $Mode completed successfully."
