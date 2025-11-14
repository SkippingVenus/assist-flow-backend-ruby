@echo off
chcp 65001 >nul
cls
echo.
echo ========================================
echo   INICIANDO ASSIST FLOW BACKEND
echo ========================================
echo.

REM Verificar que la base de datos existe
echo Verificando estado de la base de datos...
call bundle exec rake db:migrate:status >nul 2>&1
if errorlevel 1 (
    echo.
    echo Error: La base de datos no esta configurada
    echo.
    echo Ejecuta primero: configurar.bat
    echo.
    pause
    exit /b 1
)

echo Base de datos OK
echo.
echo Iniciando servidor en http://localhost:3000
echo.
echo Presiona Ctrl+C para detener el servidor
echo.
echo ----------------------------------------
echo.

REM Iniciar el servidor
call bundle exec puma -C config/puma.rb
