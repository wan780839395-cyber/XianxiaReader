[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path -Parent $PSScriptRoot
$taskLogs = Join-Path $taskRoot 'build\logs'
New-Item -ItemType Directory -Force -Path $taskLogs | Out-Null
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw 'Docker CLI is missing. This script runs only Core tests and does not build iOS.'
}

# Check engine readiness; do not launch or reset Docker Desktop from this script.
# Use a child process and timeout so a failed Desktop backend cannot hang the checkpoint.
$checkOutput = Join-Path $taskLogs 'docker-engine.stdout.log'
$checkError = Join-Path $taskLogs 'docker-engine.stderr.log'
$checkProcess = Start-Process -FilePath 'docker' -ArgumentList @('version', '--format', '{{.Server.Version}}') `
    -WindowStyle Hidden -PassThru -RedirectStandardOutput $checkOutput -RedirectStandardError $checkError
if (-not $checkProcess.WaitForExit(20000)) {
    Stop-Process -Id $checkProcess.Id -ErrorAction SilentlyContinue
    throw 'Docker engine did not respond within 20 seconds. Inspect build/logs/docker-engine.*.log.'
}
if ($checkProcess.ExitCode -ne 0) {
    throw 'Docker engine is unavailable. Inspect build/logs/docker-engine.*.log; no Swift tests were run.'
}

$taskContainer = 'xianxiareader-core-' + [guid]::NewGuid().ToString('N')
$taskLog = Join-Path $taskLogs 'core-container.log'
$taskImage = 'swift:6.1.2-jammy@sha256:1122c18e938491180820e9b4902c489dadd5a89f7e6bd99ff9b64e7f1b18f41f'
$containerFinished = $false
$containerCommand = 'set -euo pipefail; apt-get update -qq; apt-get install -y --no-install-recommends libsqlite3-dev; swift --version; swift test --package-path Packages/XianxiaCore --scratch-path /tmp/xianxia-core-build --parallel'

try {
    # Read-only source mount, no exposed ports, no Docker socket mount, no privileged container.
    & docker run --rm --platform linux/amd64 --name $taskContainer --label 'project=XianxiaReader' `
        --mount "type=bind,source=$taskRoot,target=/workspace,readonly" --workdir /workspace `
        $taskImage bash -lc $containerCommand 2>&1 | Tee-Object -FilePath $taskLog
    $testExitCode = $LASTEXITCODE
    $containerFinished = $true
    if ($testExitCode -ne 0) { throw "Core Swift compilation/tests failed with exit code $testExitCode. See $taskLog" }
} finally {
    # Remove only this randomly named container, including after Ctrl+C; never prune global resources.
    if (-not $containerFinished) {
        & docker container rm -f $taskContainer 2>$null | Out-Null
    }
}
