# Task Manager API Windows setup and launcher
# Installs Python when missing, creates a private virtual environment,
# installs the requirements, starts the API, and opens the interactive docs.

$ErrorActionPreference = "Stop"
$Root       = $PSScriptRoot
$VenvDir    = Join-Path $Root ".venv"
$VenvPython = Join-Path $VenvDir "Scripts\python.exe"
$Url        = "http://localhost:8000"

function Test-CompatiblePython([string]$Executable) {
    try {
        & $Executable -c "import sys; raise SystemExit(0 if (3, 10) <= sys.version_info[:2] < (3, 14) else 1)" 2>$null
        return $LASTEXITCODE -eq 0
    }
    catch { return $false }
}

function Find-Python {
    foreach ($Candidate in @("py", "python", "python3")) {
        $cmd = Get-Command $Candidate -ErrorAction SilentlyContinue
        # Skip the Microsoft Store stub that only opens the Store.
        if ($cmd -and $cmd.Source -notlike "*\WindowsApps\*") {
            if (Test-CompatiblePython $cmd.Source) { return $cmd.Source }
        }
    }
    $Installed = Get-ChildItem "$env:LOCALAPPDATA\Programs\Python\Python*\python.exe" -ErrorAction SilentlyContinue |
        Sort-Object FullName -Descending
    foreach ($Candidate in $Installed) {
        if (Test-CompatiblePython $Candidate.FullName) { return $Candidate.FullName }
    }
    return $null
}

Write-Host ""
Write-Host "Task Manager API setup" -ForegroundColor Cyan
Write-Host "----------------------"

$Python = Find-Python
if (-not $Python) {
    Write-Host "Python 3.10-3.13 was not found." -ForegroundColor Yellow
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw "Windows Package Manager (winget) is unavailable. Install Python 3.12 from https://www.python.org/downloads/ and run this file again."
    }
    Write-Host "Installing Python 3.12 for your Windows account..."
    winget install --exact --id Python.Python.3.12 --scope user --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) { throw "Python installation did not complete successfully." }
    $Python = Find-Python
    if (-not $Python) { throw "Python was installed but could not be located. Close this window and run run.bat again." }
}
Write-Host "Using $(& $Python --version)" -ForegroundColor Green

if (-not (Test-Path $VenvPython)) {
    Write-Host "Creating the virtual environment..."
    & $Python -m venv $VenvDir
    if ($LASTEXITCODE -ne 0) { throw "The virtual environment could not be created." }
}

Write-Host "Installing/updating required packages..."
& $VenvPython -m pip install --disable-pip-version-check -q -r (Join-Path $Root "requirements.txt")
if ($LASTEXITCODE -ne 0) { throw "The required packages could not be installed." }

if (Get-NetTCPConnection -LocalPort 8000 -State Listen -ErrorAction SilentlyContinue) {
    throw "Port 8000 is already in use. Close whatever is using it (maybe a previous Task Manager API window) and run again."
}

Write-Host ""
Write-Host "Starting Task Manager API at $Url" -ForegroundColor Green
Write-Host "Interactive docs: $Url/docs"
Write-Host "Keep this window open while using the API."
Write-Host "Press Ctrl+C here when you are finished."
Write-Host ""

# Open the docs once the server answers.
$BrowserWaitCommand = @"
for (`$Attempt = 0; `$Attempt -lt 60; `$Attempt++) {
    try {
        Invoke-WebRequest -UseBasicParsing -Uri '$Url/docs' -TimeoutSec 1 | Out-Null
        Start-Process '$Url/docs'
        break
    }
    catch {
        Start-Sleep -Seconds 1
    }
}
"@
Start-Process powershell.exe -WindowStyle Hidden -ArgumentList @("-NoProfile", "-Command", $BrowserWaitCommand)

Push-Location $Root
try {
    & $VenvPython -m uvicorn main:app --port 8000
}
finally {
    Pop-Location
}
