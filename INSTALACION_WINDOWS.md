# 🪟 Guía de Instalación en Windows

## Prerrequisitos

Para ejecutar este backend de Ruby on Rails necesitas:

### 1. Instalar Ruby 3.2.x

#### Opción A: RubyInstaller (Recomendado para Windows)

1. **Descargar RubyInstaller:**
   - Visita: https://rubyinstaller.org/downloads/
   - Descarga: **Ruby+Devkit 3.2.6-1 (x64)** o superior
   - ⚠️ IMPORTANTE: Descarga la versión **WITH DEVKIT**

2. **Instalar Ruby:**
   - Ejecuta el instalador `.exe`
   - ✅ Marca: "Add Ruby executables to your PATH"
   - ✅ Marca: "Associate .rb and .rbw files with this Ruby installation"
   - Click en "Install"

3. **Instalar MSYS2 y DevKit:**
   - Al finalizar la instalación, se abrirá una ventana de consola
   - Preguntará: "Which components shall be installed?"
   - Presiona **ENTER** para instalar todos (opción 1, 2, 3)
   - Espera a que termine (puede tomar varios minutos)

4. **Verificar instalación:**
   Abre una **NUEVA ventana de PowerShell** y ejecuta:
   ```powershell
   ruby --version
   # Debería mostrar: ruby 3.2.x
   
   gem --version
   # Debería mostrar: 3.x.x
   
   bundler --version
   # Debería mostrar: 2.x.x
   ```

   Si `bundler` no está instalado, ejecuta:
   ```powershell
   gem install bundler
   ```

### 2. Instalar PostgreSQL

1. **Descargar PostgreSQL:**
   - Visita: https://www.postgresql.org/download/windows/
   - Descarga la versión 14 o superior
   - Ejecuta el instalador

2. **Durante la instalación:**
   - Configura una contraseña para el usuario `postgres` (¡recuérdala!)
   - Puerto por defecto: 5432
   - Instala todos los componentes (incluido pgAdmin 4)

3. **Verificar instalación:**
   ```powershell
   psql --version
   # Debería mostrar: psql (PostgreSQL) 14.x o superior
   ```

### 3. Configurar el Proyecto

1. **Clonar/Navegar al proyecto:**
   ```powershell
   cd c:\Users\Omen\Documents\PrograMovil_Front\assist-flow-backend-ruby
   ```

2. **Instalar dependencias de Ruby:**
   ```powershell
   bundle install
   ```

   Si aparece error de `pg` gem:
   ```powershell
   # Instalar la gema pg manualmente
   gem install pg -- --with-pg-config="C:/Program Files/PostgreSQL/14/bin/pg_config"
   
   # Luego volver a intentar
   bundle install
   ```

3. **Configurar variables de entorno:**
   ```powershell
   copy .env.example .env
   ```

   Edita el archivo `.env` con tus credenciales:
   ```env
   DB_HOST=localhost
   DB_PORT=5432
   DB_USERNAME=postgres
   DB_PASSWORD=tu_contraseña_aqui
   JWT_SECRET_KEY=tu_clave_secreta_minimo_32_caracteres_aqui
   RAILS_ENV=development
   ```

4. **Crear la base de datos:**
   ```powershell
   rails db:create
   ```

5. **Ejecutar migraciones:**
   ```powershell
   rails db:migrate
   ```

6. **Cargar datos de prueba (opcional):**
   ```powershell
   rails db:seed
   ```

7. **Iniciar el servidor:**
   ```powershell
   rails server -p 3001
   ```

   El servidor estará disponible en: http://localhost:3001

## 🔧 Solución de Problemas Comunes

### Error: "bundle: command not found"

**Solución:**
```powershell
gem install bundler
```

### Error: "pg gem failed to build"

**Solución:**
```powershell
# Encuentra la ruta de pg_config
# Usualmente en: C:\Program Files\PostgreSQL\14\bin\pg_config

gem install pg -- --with-pg-config="C:/Program Files/PostgreSQL/14/bin/pg_config"
```

### Error: "Could not find gem 'rails'"

**Solución:**
```powershell
gem install rails -v 7.1.0
bundle install
```

### Error: "database does not exist"

**Solución:**
```powershell
rails db:create
rails db:migrate
```

### Error: "PG::ConnectionBad"

**Causas:**
- PostgreSQL no está corriendo
- Credenciales incorrectas en `.env`

**Solución:**
```powershell
# Verificar que PostgreSQL está corriendo
# Abrir "Servicios" de Windows y buscar "postgresql"
# Debe estar en estado "En ejecución"

# O desde PowerShell como administrador:
Get-Service -Name postgresql*
```

### El servidor se cierra inesperadamente

**Solución:**
```powershell
# Verifica que el puerto 3001 no esté en uso
netstat -ano | findstr :3001

# Si está en uso, mata el proceso o usa otro puerto
rails server -p 3002
```

## 🚀 Comandos Rápidos

```powershell
# Ver rutas de la API
rails routes

# Abrir consola de Rails
rails console

# Verificar estado de migraciones
rails db:migrate:status

# Revertir última migración
rails db:rollback

# Recrear base de datos (⚠️ ELIMINA TODOS LOS DATOS)
rails db:drop db:create db:migrate db:seed

# Ejecutar tests
bundle exec rspec
```

## 📚 Recursos Adicionales

- Ruby on Rails Guides: https://guides.rubyonrails.org/
- RubyInstaller para Windows: https://rubyinstaller.org/
- PostgreSQL para Windows: https://www.postgresql.org/download/windows/
- Documentación de Bundler: https://bundler.io/

## ⚡ Alternativa: Usar Backend de Node.js

Si tienes problemas instalando Ruby, puedes usar el backend de Node.js que ya está creado:

```powershell
cd c:\Users\Omen\Documents\PrograMovil_Front\assist-flow-backend
npm install
npm run dev
```

El backend de Node.js tiene las mismas funcionalidades y endpoints.
