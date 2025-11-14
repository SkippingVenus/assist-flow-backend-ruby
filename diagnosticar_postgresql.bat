@echo off
chcp 65001 >nul
cls
echo.
echo ========================================
echo   DIAGNOSTICO DE POSTGRESQL
echo ========================================
echo.

echo [1] Verificando servicios de PostgreSQL...
echo.
sc query "postgresql*" 2>nul
if errorlevel 1 (
    echo No se encontraron servicios de PostgreSQL
    echo.
    echo Verifica manualmente en Servicios de Windows:
    echo 1. Presiona Win+R
    echo 2. Escribe: services.msc
    echo 3. Busca PostgreSQL y verifica que este iniciado
) else (
    echo Servicios encontrados arriba
)
echo.
echo ========================================
echo.

echo [2] Intentando conectar a PostgreSQL...
echo.
echo Probando conexion con psql...
psql -h 127.0.0.1 -p 5432 -U postgres -c "SELECT version();" 2>nul
if errorlevel 1 (
    echo.
    echo Error: No se pudo conectar a PostgreSQL
    echo.
    echo Posibles causas:
    echo 1. PostgreSQL no esta corriendo
    echo 2. El puerto no es 5432
    echo 3. La contraseña es incorrecta
    echo 4. PostgreSQL no acepta conexiones en 127.0.0.1
    echo.
    echo SOLUCION RECOMENDADA:
    echo 1. Abre pgAdmin
    echo 2. Conectate al servidor
    echo 3. Verifica que funcione
    echo 4. Anota el puerto que usas
    echo.
) else (
    echo.
    echo Conexion exitosa!
    echo.
)

echo ========================================
echo.

echo [3] Verificando archivo pg_hba.conf...
echo.
echo El archivo pg_hba.conf debe permitir conexiones desde 127.0.0.1
echo Ubicacion tipica: C:\Program Files\PostgreSQL\[version]\data\pg_hba.conf
echo.
echo Debe contener una linea como:
echo host    all             all             127.0.0.1/32            md5
echo.
echo Si no existe, agregala y reinicia PostgreSQL.
echo.

echo ========================================
echo.

echo [4] Variables de entorno actuales:
echo.
echo DB_HOST deberia ser: 127.0.0.1
echo DB_PORT deberia ser: 5432
echo DB_USERNAME deberia ser: postgres
echo.
if exist .env (
    echo Contenido de .env:
    findstr /B "DB_" .env
) else (
    echo Archivo .env no encontrado
)
echo.

echo ========================================
echo   DIAGNOSTICO COMPLETADO
echo ========================================
echo.
pause
