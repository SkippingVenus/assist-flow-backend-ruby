# 📋 Comandos Git para Subir el Proyecto

## 🚀 Primera vez - Inicializar y Subir

```bash
# 1. Inicializar repositorio Git (si no está inicializado)
git init

# 2. Agregar todos los archivos (respetando .gitignore)
git add .

# 3. Ver qué archivos se van a subir
git status

# 4. Hacer el primer commit
git commit -m "Initial commit: AssistFlow Backend API with MVVM architecture"

# 5. Agregar el repositorio remoto (reemplaza con tu URL)
git remote add origin https://github.com/TU-USUARIO/assist-flow-backend-ruby.git

# 6. Verificar el remoto
git remote -v

# 7. Subir al repositorio (primera vez)
git push -u origin master
# O si tu rama principal es 'main':
git push -u origin main
```

## 🔄 Actualizaciones Posteriores

```bash
# 1. Ver cambios
git status

# 2. Agregar archivos modificados
git add .
# O agregar archivos específicos:
git add archivo1.rb archivo2.rb

# 3. Hacer commit con mensaje descriptivo
git commit -m "Descripción de los cambios"

# 4. Subir cambios
git push
```

## 📝 Mensajes de Commit Sugeridos

### Para Features Nuevas
```bash
git commit -m "feat: Add employee statistics service"
git commit -m "feat: Implement geolocation validation"
git commit -m "feat: Add payroll calculation endpoint"
```

### Para Fixes
```bash
git commit -m "fix: Correct late calculation logic"
git commit -m "fix: Resolve JWT token expiration issue"
```

### Para Documentación
```bash
git commit -m "docs: Update API documentation"
git commit -m "docs: Add architecture diagrams"
```

### Para Refactoring
```bash
git commit -m "refactor: Move business logic to services"
git commit -m "refactor: Improve serializer structure"
```

## 🌿 Trabajar con Ramas

```bash
# Crear nueva rama
git checkout -b feature/nueva-funcionalidad

# Ver ramas
git branch

# Cambiar de rama
git checkout master

# Mergear rama a master
git checkout master
git merge feature/nueva-funcionalidad

# Subir rama al repositorio
git push origin feature/nueva-funcionalidad
```

## 🔍 Comandos Útiles

```bash
# Ver historial de commits
git log
git log --oneline

# Ver cambios no commiteados
git diff

# Deshacer cambios en archivo
git checkout -- archivo.rb

# Deshacer último commit (mantener cambios)
git reset --soft HEAD~1

# Ver archivos ignorados
git status --ignored

# Limpiar archivos no trackeados
git clean -fd
```

## ⚠️ Archivos que NO se suben (gracias a .gitignore)

- ✅ `.env` - Variables de entorno (sensibles)
- ✅ `/log/*` - Archivos de log
- ✅ `/tmp/*` - Archivos temporales
- ✅ `/storage/*` - Archivos subidos
- ✅ `/coverage/*` - Reportes de cobertura de tests
- ✅ `.byebug_history` - Historial de debugging
- ✅ `/node_modules` - Dependencias de Node (si las hay)

## 📦 Archivos que SÍ se suben

- ✅ Todo el código fuente (`app/`, `config/`, etc.)
- ✅ Migraciones de base de datos (`db/migrate/`)
- ✅ Gemfile y Gemfile.lock
- ✅ Documentación (README, ARQUITECTURA, etc.)
- ✅ `.env.example` - Template de variables de entorno
- ✅ Tests (`spec/`)

## 🔐 Antes de Subir - Checklist

- [ ] Revisar que `.env` NO está en el repositorio
- [ ] Verificar que `.env.example` SÍ está incluido
- [ ] Comprobar que no hay credenciales en el código
- [ ] Verificar que el README.md está actualizado
- [ ] Confirmar que los tests pasan: `rspec`
- [ ] Revisar cambios con: `git status` y `git diff`

## 🌐 Crear Repositorio en GitHub

1. Ir a https://github.com/new
2. Nombre: `assist-flow-backend-ruby`
3. Descripción: `Backend API REST en Ruby on Rails para sistema de gestión de asistencias - Patrón MVVM`
4. Visibilidad: Público o Privado
5. NO inicializar con README (ya lo tienes)
6. Crear repositorio
7. Copiar la URL del repositorio
8. Usar los comandos de arriba con tu URL

## 📱 Clonar el Repositorio (para otros desarrolladores)

```bash
# Clonar repositorio
git clone https://github.com/TU-USUARIO/assist-flow-backend-ruby.git

# Entrar al directorio
cd assist-flow-backend-ruby

# Instalar dependencias
bundle install

# Copiar y configurar variables de entorno
cp .env.example .env
# Editar .env con tus credenciales

# Crear base de datos
rails db:create
rails db:migrate

# Iniciar servidor
rails server
```

## 🆘 Solución de Problemas

### Error: "failed to push some refs"
```bash
# Primero hacer pull
git pull origin master --rebase
# Luego push
git push origin master
```

### Revertir al último commit
```bash
git reset --hard HEAD
```

### Ver qué archivos están siendo ignorados
```bash
git status --ignored
```

### Eliminar archivo del staging area
```bash
git reset HEAD archivo.rb
```

## 📊 Ver Estadísticas del Repositorio

```bash
# Contar líneas de código
git ls-files | xargs wc -l

# Ver contribuidores
git shortlog -sn

# Ver archivos más modificados
git log --pretty=format: --name-only | sort | uniq -c | sort -rg | head -10
```

## 🎯 Comandos Recomendados para este Proyecto

```bash
# Paso 1: Ver qué se va a subir
git status

# Paso 2: Agregar todo
git add .

# Paso 3: Commit inicial
git commit -m "Initial commit: Backend API with MVVM architecture

- Implemented Services layer (AuthenticationService, AttendanceService, etc.)
- Created Serializers for consistent JSON responses
- Added Interactors for complex operations
- Complete API documentation
- Architecture and style guides included"

# Paso 4: Crear repo en GitHub y obtener URL

# Paso 5: Conectar y subir
git remote add origin https://github.com/TU-USUARIO/assist-flow-backend-ruby.git
git push -u origin master
```

¡Listo! Tu proyecto estará en GitHub. 🎉
