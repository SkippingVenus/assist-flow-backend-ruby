@echo off
chcp 65001 >nul
cls
echo.
echo ========================================
echo   VERIFICACION DEL SISTEMA
echo ========================================
echo.

REM Verificar Ruby
echo [1] Verificando Ruby...
ruby --version
if errorlevel 1 (
    echo    ERROR: Ruby no esta instalado
    echo.
) else (
    echo    OK
    echo.
)

REM Verificar Bundler
echo [2] Verificando Bundler...
bundle --version
if errorlevel 1 (
    echo    ERROR: Bundler no esta instalado
    echo    Ejecuta: gem install bundler
    echo.
) else (
    echo    OK
    echo.
)

REM Verificar PostgreSQL (intentar conectar)
echo [3] Verificando PostgreSQL...
psql --version >nul 2>&1
if errorlevel 1 (
    echo    ADVERTENCIA: psql no encontrado en PATH
    echo    Verifica en pgAdmin que PostgreSQL este corriendo
    echo.
) else (
    psql --version
    echo    PostgreSQL encontrado
    echo.
)

REM Verificar archivo .env
echo [4] Verificando archivo .env...
if exist .env (
    echo    OK: Archivo .env existe
    echo.
) else (
    echo    ADVERTENCIA: Archivo .env no existe
    echo    Se creara al ejecutar configurar.bat
    echo.
)

REM Verificar estado de la base de datos
echo [5] Verificando base de datos...
call bundle exec rake db:migrate:status >nul 2>&1
if errorlevel 1 (
    echo    ADVERTENCIA: Base de datos no configurada
    echo    Ejecuta: configurar.bat
    echo.
) else (
    echo    OK: Base de datos configurada
    echo.
    echo    Estado de migraciones:
    call bundle exec rake db:migrate:status 2>nul | findstr /C:"up" /C:"down"
    echo.
)

echo ========================================
echo   VERIFICACION COMPLETADA
echo ========================================
echo.
echo Si todo esta OK, ejecuta: configurar.bat
echo Luego ejecuta: start_server.bat
echo.
pause
