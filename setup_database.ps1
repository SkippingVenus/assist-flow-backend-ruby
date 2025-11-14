# Script de configuración de base de datos para Assist Flow Backend
# Este script configura y prepara la base de datos PostgreSQL

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  Configuración de Base de Datos" -ForegroundColor Cyan
Write-Host "  Assist Flow Backend Ruby" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que existe el archivo .env
if (-not (Test-Path ".env")) {
    Write-Host "⚠️  No se encontró el archivo .env" -ForegroundColor Yellow
    Write-Host "📋 Creando desde .env.example..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
    Write-Host "✅ Archivo .env creado. Por favor, verifica las credenciales." -ForegroundColor Green
    Write-Host ""
}

Write-Host "🔍 Verificando dependencias..." -ForegroundColor Blue
Write-Host ""

# Instalar gemas
Write-Host "📦 Instalando gemas..." -ForegroundColor Blue
bundle install

Write-Host ""
Write-Host "🗄️  Configurando base de datos..." -ForegroundColor Blue
Write-Host ""

# Crear base de datos
Write-Host "➕ Creando base de datos..." -ForegroundColor Yellow
bundle exec rails db:create

Write-Host ""

# Ejecutar migraciones
Write-Host "🔄 Ejecutando migraciones..." -ForegroundColor Yellow
bundle exec rails db:migrate

Write-Host ""

# Cargar seeds (datos de prueba)
Write-Host "🌱 ¿Deseas cargar datos de prueba? (S/N)" -ForegroundColor Cyan
$response = Read-Host
if ($response -eq "S" -or $response -eq "s") {
    Write-Host "📊 Cargando datos de prueba..." -ForegroundColor Yellow
    bundle exec rails db:seed
    Write-Host "✅ Datos de prueba cargados exitosamente" -ForegroundColor Green
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "  ✅ Configuración completada!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
Write-Host "Para iniciar el servidor ejecuta:" -ForegroundColor Cyan
Write-Host "  bundle exec rails server -p 3001" -ForegroundColor White
Write-Host ""
Write-Host "Credenciales de prueba (si cargaste seeds):" -ForegroundColor Cyan
Write-Host "  Email: admin@demo.com" -ForegroundColor White
Write-Host "  Password: Admin123!" -ForegroundColor White
Write-Host ""
