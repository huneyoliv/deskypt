# ==============================================================================
# DeskYPT & Companion — Interactive Quality & Testing Runner
# ==============================================================================

function Show-Header {
    Clear-Host
    Write-Host "=================================================================" -ForegroundColor Cyan
    Write-Host "       DeskYPT + DeskYPT Companion - Interactive Test Suite      " -ForegroundColor Yellow
    Write-Host "=================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Run-Tests {
    Show-Header
    Write-Host "[1] Executando suite completa de testes e analise de codigo..." -ForegroundColor Cyan
    Write-Host ""
    & "$PSScriptRoot\run_all_tests.ps1"
    Write-Host ""
    Write-Host "Pressione qualquer tecla para voltar ao menu..." -ForegroundColor Gray
    [void][System.Console]::ReadKey($true)
}

function Build-CompanionApk {
    Show-Header
    Write-Host "[2] Compilando APK do DeskYPT Companion para Android..." -ForegroundColor Cyan
    Write-Host ""
    & "$PSScriptRoot\build_companion_apk.ps1"
    
    $apkPath = "$PSScriptRoot\..\companion\build\app\outputs\flutter-apk\app-release.apk"
    if (Test-Path $apkPath) {
        Write-Host ""
        Write-Host "Deseja abrir a pasta do APK no Windows Explorer? (S/N): " -ForegroundColor Yellow -NoNewline
        $ans = Read-Host
        if ($ans -eq 'S' -or $ans -eq 's') {
            explorer.exe "/select,$apkPath"
        }
    }
    Write-Host ""
    Write-Host "Pressione qualquer tecla para voltar ao menu..." -ForegroundColor Gray
    [void][System.Console]::ReadKey($true)
}

function Test-UdpHandshake {
    Show-Header
    Write-Host "[3] Testando Handshake UDP com o DeskYPT Desktop..." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Certifique-se de que o DeskYPT Desktop esta aberto na tela de login QR Code." -ForegroundColor DarkGray
    Write-Host ""
    & "$PSScriptRoot\test_companion_udp.ps1"
    Write-Host ""
    Write-Host "Pressione qualquer tecla para voltar ao menu..." -ForegroundColor Gray
    [void][System.Console]::ReadKey($true)
}

function Start-DesktopApp {
    Show-Header
    Write-Host "[4] Iniciando DeskYPT Desktop (Windows)..." -ForegroundColor Cyan
    Write-Host ""
    Push-Location "$PSScriptRoot\.."
    try {
        flutter run -d windows
    } finally {
        Pop-Location
    }
    Write-Host ""
    Write-Host "Pressione qualquer tecla para voltar ao menu..." -ForegroundColor Gray
    [void][System.Console]::ReadKey($true)
}

do {
    Show-Header
    Write-Host "Escolha uma opcao:" -ForegroundColor White
    Write-Host "  [1] Executar todos os testes (Desktop + Companion APK)" -ForegroundColor Cyan
    Write-Host "  [2] Compilar APK Release do Companion (com.deskypt.companion)" -ForegroundColor Green
    Write-Host "  [3] Simular Handshake UDP (Zero-Touch Auto-Sync)" -ForegroundColor Yellow
    Write-Host "  [4] Executar DeskYPT Desktop no Windows (flutter run)" -ForegroundColor Magenta
    Write-Host "  [0] Sair" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "Opcao: " -ForegroundColor Yellow -NoNewline
    $choice = Read-Host

    switch ($choice) {
        '1' { Run-Tests }
        '2' { Build-CompanionApk }
        '3' { Test-UdpHandshake }
        '4' { Start-DesktopApp }
        '0' { break }
        default {
            Write-Host "Opcao invalida. Tente novamente." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
} while ($choice -ne '0')

Show-Header
Write-Host "Obrigado por usar o DeskYPT!" -ForegroundColor Cyan
