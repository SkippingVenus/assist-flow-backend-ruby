# README - Configuración e Inicio del Backend

## 🚀 INICIO RÁPIDO

### 1. Configurar el Backend (Primera vez)

Abre PowerShell en esta carpeta y ejecuta:

```powershell
.\configurar.ps1
```

Este script hará:
- ✅ Verificar que todo esté listo
- ✅ Instalar las dependencias necesarias
- ✅ Crear la base de datos PostgreSQL
- ✅ Ejecutar las migraciones (crear tablas)
- ✅ Opcionalmente cargar datos de prueba

### 2. Iniciar el Servidor

```powershell
.\start_server.ps1
```

El servidor estará disponible en: **http://localhost:3001**

---

## ⚙️ CONFIGURACIÓN DE POSTGRESQL

Antes de ejecutar `.\configurar.ps1`, asegúrate de que:

1. **PostgreSQL esté instalado y corriendo**
   - Verifica en "Servicios" de Windows que PostgreSQL esté activo
   - O usa pgAdmin para verificar

2. **Configuración esperada:**
   - Puerto: **5432**
   - Usuario: **postgres**
   - Contraseña: **admin**

3. **Si tus credenciales son diferentes:**
   - Edita el archivo `.env` y cambia:
     ```env
     DB_PORT=5432
     DB_USERNAME=postgres
     DB_PASSWORD=tu_contraseña_aqui
     ```

---

## 📁 ESTRUCTURA DE LA BASE DE DATOS

El backend creará estas tablas en PostgreSQL:

### Tablas Principales
- **companies** - Empresas registradas
- **profiles** - Perfiles de administradores
- **employees** - Empleados de las empresas
- **company_locations** - Ubicaciones de trabajo (geofences)
- **attendance_records** - Registros de asistencia
- **vacation_requests** - Solicitudes de vacaciones
- **payroll_calculations** - Cálculos de nómina
- **notifications** - Notificaciones del sistema

---

## 🔐 DATOS DE PRUEBA

Si cargaste los datos de prueba (seeds), tendrás:

### Administrador
- **Email:** admin@demo.com
- **Contraseña:** Admin123!

### Empleados de Prueba
- 5 empleados con PINs: 1001, 1002, 1003, 1004, 1005
- Contraseña para todos: Employee123!

---

## 🌐 ENDPOINTS PRINCIPALES

Base URL: `http://localhost:3001/api/v1`

### Autenticación
- `POST /auth/register` - Registrar empresa + admin
- `POST /auth/admin_login` - Login de administrador
- `POST /auth/employee_login` - Login de empleado

### Empleados (requieren autenticación)
- `GET /employees` - Listar empleados
- `POST /employees` - Crear empleado
- `GET /employees/:id` - Ver un empleado

### Asistencia (requieren autenticación)
- `POST /attendance_records` - Registrar asistencia
- `GET /attendance_records/today` - Resumen del día
- `GET /attendance_records` - Historial

Ver documentación completa en: **API_DOCUMENTATION.md**

---

## 🔧 COMANDOS ÚTILES

### Verificar estado de migraciones
```powershell
bundle exec rake db:migrate:status
```

### Resetear base de datos (¡CUIDADO! Borra todo)
```powershell
bundle exec rake db:reset
```

### Abrir consola de Rails
```powershell
bundle exec rails console
```

### Ver todas las rutas
```powershell
bundle exec rake routes
```

### Ejecutar tests
```powershell
bundle exec rspec
```

---

## 🐛 SOLUCIÓN DE PROBLEMAS

### Error: "could not connect to server"
**Solución:**
- Verifica que PostgreSQL esté corriendo
- Revisa que el puerto sea 5432
- Verifica usuario y contraseña en `.env`

### Error: "database does not exist"
**Solución:**
```powershell
bundle exec rake db:create
```

### Error: "pending migrations"
**Solución:**
```powershell
bundle exec rake db:migrate
```

### Error con la gema `pg`
**Solución:**
```powershell
gem install pg --platform=x64-mingw-ucrt
bundle install
```

### El servidor no responde
**Solución:**
- Verifica que no haya otro proceso en el puerto 3001
- Revisa los logs en la terminal donde ejecutaste el servidor
- Intenta reiniciar el servidor

---

## 📚 DOCUMENTACIÓN ADICIONAL

- **API_DOCUMENTATION.md** - Documentación completa de todos los endpoints
- **ARQUITECTURA_MVVM.md** - Explicación de la arquitectura del proyecto
- **INSTALACION_WINDOWS.md** - Guía detallada de instalación en Windows
- **EJEMPLOS_USO.md** - Ejemplos de cómo usar la API
- **GUIA_INICIO_RAPIDO.md** - Guía detallada de inicio rápido

---

## 🆘 ¿NECESITAS AYUDA?

1. Revisa los logs en la terminal donde ejecutas el servidor
2. Consulta la documentación adicional en la carpeta del proyecto
3. Verifica que PostgreSQL esté corriendo y configurado correctamente
4. Asegúrate de que las credenciales en `.env` sean correctas

---

## 📝 PRÓXIMOS PASOS

1. ✅ Configurar el backend (este archivo)
2. ✅ Iniciar el servidor
3. 📱 Conectar con la aplicación móvil Flutter
4. 🧪 Probar los endpoints con Postman o similar
5. 🎨 Personalizar según tus necesidades

---

**¡Listo para empezar! Ejecuta `.\configurar.ps1` y luego `.\start_server.ps1`**
