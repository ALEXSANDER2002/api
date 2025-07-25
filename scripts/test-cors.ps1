Write-Host "🧪 Testando configuração do CORS..." -ForegroundColor Green
Write-Host ""

# URL da API
$API_URL = "http://localhost:3000"

Write-Host "1. Testando requisição simples (GET /health):" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$API_URL/health" -Method GET -Headers @{
        "Origin" = "http://localhost:3000"
        "Content-Type" = "application/json"
    } -ErrorAction Stop
    Write-Host "✅ Sucesso: $($response | ConvertTo-Json)" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "2. Testando requisição mobile (POST /sync):" -ForegroundColor Yellow
try {
    $body = @{
        users = @()
        inspections = @()
        photos = @()
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "$API_URL/sync" -Method POST -Headers @{
        "Origin" = "http://localhost:3000"
        "Content-Type" = "application/json"
        "X-Client-Type" = "mobile"
    } -Body $body -ErrorAction Stop
    Write-Host "✅ Sucesso: $($response | ConvertTo-Json)" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "3. Testando requisição sem origin (como app mobile):" -ForegroundColor Yellow
try {
    $body = @{
        users = @()
        inspections = @()
        photos = @()
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "$API_URL/sync" -Method POST -Headers @{
        "Content-Type" = "application/json"
        "X-Client-Type" = "mobile"
    } -Body $body -ErrorAction Stop
    Write-Host "✅ Sucesso: $($response | ConvertTo-Json)" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "4. Testando requisição com origin não permitida:" -ForegroundColor Yellow
try {
    $body = @{
        users = @()
        inspections = @()
        photos = @()
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "$API_URL/sync" -Method POST -Headers @{
        "Origin" = "http://malicious-site.com"
        "Content-Type" = "application/json"
        "X-Client-Type" = "mobile"
    } -Body $body -ErrorAction Stop
    Write-Host "✅ Sucesso: $($response | ConvertTo-Json)" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "✅ Testes de CORS concluídos!" -ForegroundColor Green 