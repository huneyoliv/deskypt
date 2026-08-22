# DeskYPT Companion - Build Android APK

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "  DeskYPT Companion - Compilando APK de Release Android" -ForegroundColor Yellow
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host ""

Push-Location "$PSScriptRoot\..\companion"
try {
    Write-Host "[1/2] Obtendo dependencias do Companion..." -ForegroundColor Cyan
    flutter pub get
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERRO: Falha ao obter dependencias!" -ForegroundColor Red
        exit 1
    }

    Write-Host ""
    Write-Host "[2/2] Compilando APK Release (com.deskypt.companion)..." -ForegroundColor Cyan
    flutter build apk --release
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERRO: Falha no build do APK!" -ForegroundColor Red
        exit 1
    }

    $apkPath = "$PSScriptRoot\..\companion\build\app\outputs\flutter-apk\app-release.apk"
    if (Test-Path $apkPath) {
        $apkSize = (Get-Item $apkPath).Length / 1MB
        $sizeRounded = [Math]::Round($apkSize, 2)
        Write-Host ""
        Write-Host "APK COMPILADO COM SUCESSO!" -ForegroundColor Green
        Write-Host "Local: $apkPath" -ForegroundColor Yellow
        Write-Host "Tamanho: $sizeRounded MB" -ForegroundColor Cyan
        Write-Host "Instale no celular via adb install ou transferindo o arquivo APK." -ForegroundColor DarkGray
    }
} finally {
    Pop-Location
}
