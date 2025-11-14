@echo off
chcp 65001 >nul
cls
echo.
echo ========================================
echo   RESETEAR BASE DE DATOS
echo ========================================
echo.
echo ADVERTENCIA: Esta operacion borrara TODOS los datos
echo              de la base de datos y la recreara desde cero.
echo.
echo ¿Estas completamente seguro? (S/N): 
set /p confirmar=
if /i not "%confirmar%"=="S" (
    echo.
    echo Operacion cancelada.
    echo.
    pause
    exit /b
)

echo.
echo Confirmacion final. Escribe SI en mayusculas para continuar:
set /p confirmar2=
if not "%confirmar2%"=="SI" (
    echo.
    echo Operacion cancelada.
    echo.
    pause
    exit /b
)

echo.
echo Reseteando base de datos...
echo.
call bundle exec rake db:reset

if errorlevel 1 (
    echo.
    echo Error al resetear la base de datos
    echo.
    pause
    exit /b 1
)

echo.
echo Base de datos reseteada exitosamente
echo.
echo ¿Deseas cargar datos de prueba? (S/N): 
set /p cargar_seeds=
if /i "%cargar_seeds%"=="S" (
    echo.
    echo Cargando datos de prueba...
    call bundle exec rake db:seed
    echo.
    echo Datos de prueba cargados
    echo.
)

echo.
echo ========================================
echo   PROCESO COMPLETADO
echo ========================================
echo.
pause
