@echo off
chcp 65001 >nul
cls
echo.
echo ========================================
echo   CONFIGURAR CONTRASEÑA DE POSTGRESQL
echo ========================================
echo.
echo El error indica que la contraseña es incorrecta.
echo.
echo La contraseña actual en .env es: admin
echo.
echo ¿Cual es la contraseña REAL de tu usuario postgres?
echo (la que configuraste cuando instalaste PostgreSQL)
echo.
set /p password=Escribe la contraseña: 

echo.
echo Actualizando archivo .env...
echo.

REM Crear archivo temporal
(
echo # Database configuration
echo DB_HOST=127.0.0.1
echo DB_PORT=5432
echo DB_USERNAME=postgres
echo DB_PASSWORD=%password%
echo.
echo # JWT Secret Key
echo JWT_SECRET_KEY=a7f8e9d2c5b1a4e8f7d6c3b9a2e5f8d1c4b7a0e3f6d9c2b5a8e1f4d7c0b3a6e9f2
echo.
echo # JWT Expiration ^(in hours^)
echo JWT_EXPIRATION_HOURS=24
echo.
echo # CORS Allowed Origins ^(comma separated^)
echo CORS_ORIGINS=http://localhost:5173,http://localhost:3000,http://localhost:5174
echo.
echo # Rails Environment
echo RAILS_ENV=development
echo.
echo # Server Port
echo PORT=3000
echo.
echo # Mapbox Token ^(optional^)
echo MAPBOX_ACCESS_TOKEN=
echo.
echo # Rate Limiting
echo RATE_LIMIT_REQUESTS=100
echo RATE_LIMIT_PERIOD=900
) > .env

echo Contraseña actualizada en .env
echo.
echo Intentando conectar a la base de datos...
echo.

bundle exec rake db:create

if errorlevel 1 (
    echo.
    echo ========================================
    echo   ERROR: La contraseña sigue siendo incorrecta
    echo ========================================
    echo.
    echo Verifica tu contraseña en pgAdmin:
    echo 1. Abre pgAdmin
    echo 2. Intenta conectarte
    echo 3. Usa la contraseña que funciona ahi
    echo 4. Ejecuta este script de nuevo con esa contraseña
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo   CONEXION EXITOSA!
echo ========================================
echo.
echo ¿Continuar con las migraciones? ^(S/N^): 
set /p continuar=

if /i "%continuar%"=="S" (
    echo.
    echo Ejecutando migraciones...
    bundle exec rake db:migrate
    
    echo.
    echo ¿Cargar datos de prueba? ^(S/N^): 
    set /p seeds=
    
    if /i "%seeds%"=="S" (
        bundle exec rake db:seed
        echo.
        echo Datos de prueba cargados!
    )
)

echo.
echo ========================================
echo   CONFIGURACION COMPLETADA
echo ========================================
echo.
echo Ya puedes iniciar el servidor con:
echo   start_server.bat
echo.
pause
