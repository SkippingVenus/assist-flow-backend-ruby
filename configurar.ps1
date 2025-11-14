# ====================================
# Configuración Completa del Backend
# ====================================

Write-Host ""
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  ASSIST FLOW BACKEND - CONFIGURACIÓN  ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Paso 1: Verificar PostgreSQL
Write-Host "📋 PASO 1: Verificando PostgreSQL..." -ForegroundColor Yellow
Write-Host ""
Write-Host "   Asegúrate de que PostgreSQL esté corriendo en puerto 5432" -ForegroundColor White
Write-Host "   Credenciales esperadas:" -ForegroundColor White
Write-Host "   - Usuario: postgres" -ForegroundColor Gray
Write-Host "   - Contraseña: admin" -ForegroundColor Gray
Write-Host "   - Puerto: 5432" -ForegroundColor Gray
Write-Host ""
Write-Host "   ¿Continuar? (S/N): " -ForegroundColor Cyan -NoNewline
$response = Read-Host
if ($response -ne "S" -and $response -ne "s") {
    Write-Host "❌ Configuración cancelada" -ForegroundColor Red
    exit
}

# Paso 2: Instalar dependencias
Write-Host ""
Write-Host "📦 PASO 2: Instalando dependencias Ruby..." -ForegroundColor Yellow
try {
    bundle install
    Write-Host "✅ Dependencias instaladas correctamente" -ForegroundColor Green
} catch {
    Write-Host "❌ Error instalando dependencias" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# Paso 3: Crear base de datos
Write-Host ""
Write-Host "🗄️  PASO 3: Creando base de datos..." -ForegroundColor Yellow
try {
    bundle exec rake db:create 2>&1 | Out-Null
    Write-Host "✅ Base de datos creada" -ForegroundColor Green
} catch {
    Write-Host "⚠️  La base de datos ya existe o hubo un error" -ForegroundColor Yellow
}

# Paso 4: Ejecutar migraciones
Write-Host ""
Write-Host "🔄 PASO 4: Ejecutando migraciones..." -ForegroundColor Yellow
try {
    bundle exec rake db:migrate
    Write-Host "✅ Migraciones ejecutadas correctamente" -ForegroundColor Green
} catch {
    Write-Host "❌ Error ejecutando migraciones" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# Paso 5: Cargar datos de prueba (opcional)
Write-Host ""
Write-Host "🌱 PASO 5: ¿Deseas cargar datos de prueba? (S/N): " -ForegroundColor Yellow -NoNewline
$seedResponse = Read-Host
if ($seedResponse -eq "S" -or $seedResponse -eq "s") {
    try {
        bundle exec rake db:seed
        Write-Host "✅ Datos de prueba cargados" -ForegroundColor Green
        Write-Host ""
        Write-Host "   📧 Credenciales de prueba:" -ForegroundColor Cyan
        Write-Host "   Email: admin@demo.com" -ForegroundColor White
        Write-Host "   Password: Admin123!" -ForegroundColor White
    } catch {
        Write-Host "❌ Error cargando datos de prueba" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

# Resumen final
Write-Host ""
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║     ✅ CONFIGURACIÓN COMPLETADA       ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 Para iniciar el servidor ejecuta:" -ForegroundColor Cyan
Write-Host "   .\start_server.ps1" -ForegroundColor White
Write-Host ""
Write-Host "   O manualmente:" -ForegroundColor Cyan
Write-Host "   bundle exec rails server -p 3001" -ForegroundColor White
Write-Host ""
