# Script para iniciar el servidor Assist Flow Backend
# Ejecuta el servidor Rails en el puerto 3001

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  🚀 Iniciando Assist Flow Backend" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que la base de datos existe
Write-Host "🔍 Verificando estado de la base de datos..." -ForegroundColor Blue
$dbStatus = bundle exec rails db:migrate:status 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Error: La base de datos no está configurada" -ForegroundColor Red
    Write-Host "📋 Ejecuta primero: .\setup_database.ps1" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host "✅ Base de datos OK" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 Iniciando servidor en http://localhost:3001" -ForegroundColor Cyan
Write-Host "⏹️  Presiona Ctrl+C para detener el servidor" -ForegroundColor Yellow
Write-Host ""

# Iniciar el servidor
bundle exec rails server -p 3001
