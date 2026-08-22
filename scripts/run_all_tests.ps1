# DeskYPT & DeskYPT Companion - Full Test Suite Runner

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "  DeskYPT + DeskYPT Companion - Automated Quality Assurance Runner" -ForegroundColor Yellow
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host ""

$startTime = Get-Date

# 1. DeskYPT Desktop
Write-Host "[1/4] Running DeskYPT Desktop Tests..." -ForegroundColor Cyan
Push-Location "$PSScriptRoot\.."
try {
    flutter test
    if ($LASTEXITCODE -ne 0) {
        Write-Host "FAIL: DeskYPT Desktop tests failed!" -ForegroundColor Red
        exit 1
    }
    Write-Host "SUCCESS: DeskYPT Desktop tests passed!" -ForegroundColor Green

    Write-Host ""
    Write-Host "[2/4] Analyzing DeskYPT Desktop Code..." -ForegroundColor Cyan
    flutter analyze
    if ($LASTEXITCODE -ne 0) {
        Write-Host "FAIL: DeskYPT Desktop analysis failed!" -ForegroundColor Red
        exit 1
    }
    Write-Host "SUCCESS: DeskYPT Desktop code clean - 0 issues!" -ForegroundColor Green
} finally {
    Pop-Location
}

Write-Host ""
# 2. DeskYPT Companion APK
Write-Host "[3/4] Running DeskYPT Companion APK Tests..." -ForegroundColor Cyan
Push-Location "$PSScriptRoot\..\companion"
try {
    flutter test
    if ($LASTEXITCODE -ne 0) {
        Write-Host "FAIL: DeskYPT Companion tests failed!" -ForegroundColor Red
        exit 1
    }
    Write-Host "SUCCESS: DeskYPT Companion tests passed!" -ForegroundColor Green

    Write-Host ""
    Write-Host "[4/4] Analyzing DeskYPT Companion Code..." -ForegroundColor Cyan
    flutter analyze
    if ($LASTEXITCODE -ne 0) {
        Write-Host "FAIL: DeskYPT Companion analysis failed!" -ForegroundColor Red
        exit 1
    }
    Write-Host "SUCCESS: DeskYPT Companion code clean - 0 issues!" -ForegroundColor Green
} finally {
    Pop-Location
}

$duration = (Get-Date) - $startTime
$seconds = [Math]::Round($duration.TotalSeconds, 1)

Write-Host ""
Write-Host "=================================================================" -ForegroundColor Green
Write-Host "  ALL 323+ TESTS AND CODE ANALYZERS PASSED IN $seconds s!" -ForegroundColor Green
Write-Host "=================================================================" -ForegroundColor Green
