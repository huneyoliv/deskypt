# DeskYPT Companion - UDP Simulation Test Script
# Envia um datagrama UDP de autenticacao simulada para testar o auto-sync do DeskYPT Desktop.

param(
    [string]$TargetIp = "127.0.0.1",
    [int]$Port = 47221,
    [string]$Jwt = "simulated_companion_jwt_token_sample",
    [string]$Email = "teste.companion@ypt.com",
    [string]$Name = "Usuario Teste Companion"
)

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "  DeskYPT Companion - UDP Handshake Simulator" -ForegroundColor Yellow
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "Alvo: $TargetIp:$Port" -ForegroundColor DarkGray
Write-Host "Email: $Email" -ForegroundColor DarkGray
Write-Host "Nome: $Name" -ForegroundColor DarkGray
Write-Host ""

$now = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()

$payload = @{
    type      = "deskypt-companion-auth"
    version   = 1
    jwt       = $Jwt
    email     = $Email
    name      = $Name
    timestamp = $now
} | ConvertTo-Json -Compress

$udpClient = New-Object System.Net.Sockets.UdpClient
$udpClient.Client.ReceiveTimeout = 4000
$endpoint = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Parse($TargetIp), $Port)

try {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($payload)
    Write-Host "[>] Enviando broadcast UDP para $TargetIp:$Port..." -ForegroundColor Cyan
    $sent = $udpClient.Send($bytes, $bytes.Length, $endpoint)
    Write-Host "[OK] $sent bytes enviados. Aguardando ACK do DeskYPT..." -ForegroundColor Green

    $remoteEndpoint = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Any, 0)
    $responseBytes = $udpClient.Receive([ref]$remoteEndpoint)
    $responseString = [System.Text.Encoding]::UTF8.GetString($responseBytes)
    
    Write-Host ""
    Write-Host "RESPOSTA RECEBIDA DO DESKYPT DESKTOP:" -ForegroundColor Green
    Write-Host "De: $($remoteEndpoint.Address):$($remoteEndpoint.Port)" -ForegroundColor Yellow
    Write-Host "Mensagem: $responseString" -ForegroundColor Cyan
} catch [System.Net.Sockets.SocketException] {
    Write-Host "AVISO: Tempo limite esgotado sem resposta ACK." -ForegroundColor Yellow
    Write-Host "Certifique-se de que a tela de login com QR Code esta aberta no DeskYPT Desktop." -ForegroundColor DarkGray
} catch {
    Write-Host "ERRO: $_" -ForegroundColor Red
} finally {
    $udpClient.Close()
}
