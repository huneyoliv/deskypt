# DeskYPT - Full Test Suite Runner

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "         DeskYPT - Automated Quality Assurance Runner            " -ForegroundColor Yellow
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host ""

$startTime = Get-Date

# DeskYPT Desktop
Write-Host "[1/2] Running DeskYPT Desktop Tests..." -ForegroundColor Cyan
Push-Location "$PSScriptRoot\.."
try {
    flutter test
    if ($LASTEXITCODE -ne 0) {
        Write-Host "FAIL: DeskYPT Desktop tests failed!" -ForegroundColor Red
        exit 1
    }
    Write-Host "SUCCESS: DeskYPT Desktop tests passed!" -ForegroundColor Green

    Write-Host ""
    Write-Host "[2/2] Analyzing DeskYPT Desktop Code..." -ForegroundColor Cyan
    flutter analyze
    if ($LASTEXITCODE -ne 0) {
        Write-Host "FAIL: DeskYPT Desktop analysis failed!" -ForegroundColor Red
        exit 1
    }
    Write-Host "SUCCESS: DeskYPT Desktop code clean - 0 issues!" -ForegroundColor Green
} finally {
    Pop-Location
}

$duration = (Get-Date) - $startTime
$seconds = [Math]::Round($duration.TotalSeconds, 1)

Write-Host ""
Write-Host "=================================================================" -ForegroundColor Green
Write-Host "  ALL TESTS AND CODE ANALYZERS PASSED IN $seconds s!" -ForegroundColor Green
Write-Host "=================================================================" -ForegroundColor Green
