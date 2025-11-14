@echo off
chcp 65001 >nul
cls
echo.
echo ========================================
echo   ASSIST FLOW BACKEND - CONFIGURACION
echo ========================================
echo.

REM Verificar PostgreSQL
echo [PASO 1] Verificando PostgreSQL...
echo.
echo   Asegurate de que PostgreSQL este corriendo en puerto 5432
echo   Credenciales esperadas:
echo   - Usuario: postgres
echo   - Contraseña: postgres
echo   - Puerto: 5432
echo.
set /p continuar="   ¿Continuar? (S/N): "
if /i not "%continuar%"=="S" (
    echo.
    echo Configuracion cancelada.
    exit /b
)

REM Instalar dependencias
echo.
echo [PASO 2] Instalando dependencias Ruby...
echo.
call bundle install
if errorlevel 1 (
    echo.
    echo Error instalando dependencias
    pause
    exit /b 1
)
echo.
echo Dependencias instaladas correctamente
echo.

REM Crear base de datos
echo [PASO 3] Creando base de datos...
echo.
call bundle exec rake db:create 2>nul
echo Base de datos verificada
echo.

REM Ejecutar migraciones
echo [PASO 4] Ejecutando migraciones...
echo.
call bundle exec rake db:migrate
if errorlevel 1 (
    echo.
    echo Error ejecutando migraciones
    pause
    exit /b 1
)
echo.
echo Migraciones ejecutadas correctamente
echo.

REM Cargar seeds
echo [PASO 5] ¿Deseas cargar datos de prueba? (S/N): 
set /p cargar_seeds=
if /i "%cargar_seeds%"=="S" (
    echo.
    echo Cargando datos de prueba...
    call bundle exec rake db:seed
    echo.
    echo Datos de prueba cargados
    echo.
    echo   Credenciales de prueba:
    echo   Email: admin@demo.com
    echo   Password: Admin123!
    echo.
)

REM Resumen final
echo.
echo ========================================
echo      CONFIGURACION COMPLETADA
echo ========================================
echo.
echo Para iniciar el servidor ejecuta:
echo   start_server.bat
echo.
echo O manualmente:
echo   bundle exec rails server -p 3001
echo.
pause
