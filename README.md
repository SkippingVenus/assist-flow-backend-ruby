# AsistControl - Backend Ruby on Rails API

Sistema de control de asistencia empresarial con arquitectura MVVM (Model-View-ViewModel).

## 🏗️ Arquitectura MVVM

Este proyecto implementa el patrón MVVM adaptado para APIs REST:

### Modelos (Models)
Capa de datos y persistencia usando ActiveRecord:
- `Company` - Empresas
- `Employee` - Empleados  
- `Profile` - Administradores
- `AttendanceRecord` - Registros de asistencia
- `CompanyLocation` - Ubicaciones de empresa
- `VacationRequest` - Solicitudes de vacaciones
- `PayrollCalculation` - Cálculos de nómina
- `Notification` - Notificaciones

### ViewModels
Lógica de presentación y negocio:
- `EmployeeViewModel` - Gestión de credenciales y datos de empleados
- `AttendanceViewModel` - Registro de asistencia, validación geográfica, estadísticas
- `PayrollViewModel` - Cálculos de nómina y reportes
- `DashboardViewModel` - Estadísticas agregadas del dashboard

### Controladores (Controllers)
Orquestación de peticiones y respuestas:
- `AuthController` - Registro y autenticación
- `EmployeesController` - CRUD de empleados
- `CompaniesController` - Gestión de empresas y ubicaciones
- `AttendanceRecordsController` - Registro y consulta de asistencia
- `VacationRequestsController` - Solicitudes de vacaciones
- `NotificationsController` - Notificaciones
- `PayrollCalculationsController` - Cálculos de nómina
- `ReportsController` - Reportes y dashboard

## 🚀 Stack Tecnológico

- Ruby 3.2.0+
- Rails 7.1+ (API mode)
- PostgreSQL 14+
- JWT para autenticación
- BCrypt para encriptación de passwords

## ⚙️ Instalación

### Prerrequisitos
- Ruby 3.2.0 o superior
- PostgreSQL 14 o superior
- Bundler

> **📝 Nota para usuarios de Windows:** Si no tienes Ruby instalado, revisa la guía detallada en [INSTALACION_WINDOWS.md](INSTALACION_WINDOWS.md)

### Pasos Rápidos

1. **Navegar al proyecto**
```bash
cd assist-flow-backend-ruby
```

2. **Instalar dependencias**
```bash
bundle install
```

3. **Configurar variables de entorno**
```bash
copy .env.example .env
# Editar .env con tus credenciales de PostgreSQL
```

4. **Crear base de datos**
```bash
rails db:create
```

5. **Ejecutar migraciones**
```bash
rails db:migrate
```

6. **Cargar datos de prueba (opcional)**
```bash
rails db:seed
```

7. **Iniciar servidor**
```bash
rails server -p 3001
```

El servidor estará disponible en `http://localhost:3001`

### 🔧 Problemas con la instalación?

- **Windows:** Ver [INSTALACION_WINDOWS.md](INSTALACION_WINDOWS.md) para guía completa
- **Error con `bundle`:** Ejecuta `gem install bundler`
- **Error con `pg` gem:** Ver sección de troubleshooting en la guía de Windows

## 📁 Estructura del Proyecto

```
assist-flow-backend-ruby/
├── app/
│   ├── controllers/
│   │   └── api/
│   │       └── v1/
│   │           ├── base_controller.rb
│   │           ├── auth_controller.rb
│   │           ├── employees_controller.rb
│   │           ├── companies_controller.rb
│   │           ├── attendance_records_controller.rb
│   │           ├── vacation_requests_controller.rb
│   │           ├── notifications_controller.rb
│   │           ├── payroll_calculations_controller.rb
│   │           └── reports/
│   │               └── reports_controller.rb
│   ├── models/
│   │   ├── company.rb
│   │   ├── employee.rb
│   │   ├── profile.rb
│   │   ├── attendance_record.rb
│   │   ├── company_location.rb
│   │   ├── vacation_request.rb
│   │   ├── payroll_calculation.rb
│   │   └── notification.rb
│   └── view_models/
│       ├── employee_view_model.rb
│       ├── attendance_view_model.rb
│       ├── payroll_view_model.rb
│       └── dashboard_view_model.rb
├── config/
│   ├── database.yml
│   ├── routes.rb
│   └── initializers/
│       └── cors.rb
├── db/
│   ├── migrate/
│   └── seeds.rb
├── lib/
│   └── json_web_token.rb
├── Gemfile
└── .env.example
```

## 🔌 Endpoints de la API

### Base URL
```
http://localhost:3001/api/v1
```

### Autenticación

#### Registro de Empresa + Admin
```bash
POST /api/v1/auth/register
Content-Type: application/json

{
  "company_name": "Mi Empresa",
  "email": "admin@empresa.com",
  "password": "Password123!",
  "full_name": "Admin Usuario"
}
```

#### Login Administrador
```bash
POST /api/v1/auth/admin_login
Content-Type: application/json

{
  "email": "admin@empresa.com",
  "password": "Password123!"
}
```

#### Login Empleado
```bash
POST /api/v1/auth/employee_login
Content-Type: application/json

{
  "company_id": "uuid",
  "pin": "1234",
  "password": "Pass5678"
}
```

### Empleados

#### Listar Empleados
```bash
GET /api/v1/employees
Authorization: Bearer <token>
```

#### Crear Empleado
```bash
POST /api/v1/employees
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Juan Pérez",
  "dni": "12345678",
  "phone": "999888777",
  "email": "juan@empresa.com",
  "job_position": "Desarrollador",
  "salary": 3500
}
```

### Asistencia

#### Registrar Asistencia
```bash
POST /api/v1/attendance_records
Authorization: Bearer <token>
Content-Type: application/json

{
  "attendance_type": "entrance",
  "latitude": -12.046374,
  "longitude": -77.042793
}
```

#### Resumen de Hoy
```bash
GET /api/v1/attendance_records/today
Authorization: Bearer <token>
```

### Vacaciones

#### Crear Solicitud
```bash
POST /api/v1/vacation_requests
Authorization: Bearer <token>
Content-Type: application/json

{
  "start_date": "2025-02-01",
  "end_date": "2025-02-07",
  "reason": "Vacaciones programadas"
}
```

#### Aprobar Solicitud
```bash
POST /api/v1/vacation_requests/:id/approve
Authorization: Bearer <token>
```

### Nómina

#### Calcular Nómina
```bash
POST /api/v1/payroll_calculations/calculate
Authorization: Bearer <token>
Content-Type: application/json

{
  "period_start": "2025-01-01",
  "period_end": "2025-01-31"
}
```

### Reportes

#### Dashboard
```bash
GET /api/v1/reports/dashboard
Authorization: Bearer <token>
```

#### Reporte de Asistencia
```bash
GET /api/v1/reports/attendance?start_date=2025-01-01&end_date=2025-01-31
Authorization: Bearer <token>
```

## 🌟 Características Principales

### Autenticación Dual
- **Administradores**: Email + Password
- **Empleados**: PIN (4 dígitos) + Password

### Geolocalización
- Validación de ubicación al registrar asistencia
- Cálculo de distancia usando fórmula de Haversine
- Múltiples ubicaciones por empresa

### Cálculo de Tardanzas
- Detección automática de llegadas tardías
- Registro de minutos de retraso
- Notificaciones automáticas

### Gestión de Nómina
- Cálculo automático desde registros de asistencia
- Horas trabajadas, horas extras
- Bonos y deducciones
- Exportación a Excel (preparado)

### Reportes
- Dashboard con estadísticas
- Reportes de asistencia por período
- Reporte de tardanzas
- Estadísticas mensuales

## 🔐 Autenticación

Todas las rutas protegidas requieren un header de autorización:

```http
Authorization: Bearer <jwt_token>
```

## 🔒 Seguridad

- Autenticación JWT
- Passwords encriptados con BCrypt
- PINs hasheados
- Validación de permisos por tipo de usuario
- CORS configurado
- Rate limiting (Rack Attack)

## 🧪 Testing

Ejecutar tests:
```bash
bundle exec rspec
```

## 🌱 Seeds (Datos de Prueba)

```bash
rails db:seed
```

Esto creará:
- 1 empresa de ejemplo
- 1 administrador (admin@demo.com / Admin123!)
- 5 empleados de prueba
- Registros de asistencia de los últimos 7 días
- Solicitudes de vacaciones
- Notificaciones

## 📝 Comandos Útiles

```bash
# Consola de Rails
rails console

# Verificar rutas
rails routes

# Generar una nueva migración
rails g migration AddColumnToTable

# Rollback de última migración
rails db:rollback

# Ver estado de migraciones
rails db:migrate:status
```

## � Producción

### Variables de Entorno Requeridas

```env
RAILS_ENV=production
DATABASE_URL=postgresql://user:password@host:port/database
JWT_SECRET_KEY=your-secret-key-min-32-chars
ALLOWED_ORIGINS=https://your-frontend.com
```

### Deployment

1. Configurar servidor con Ruby 3.2+
2. Instalar PostgreSQL
3. Configurar variables de entorno
4. Ejecutar migraciones
5. Iniciar con Puma

```bash
RAILS_ENV=production rails db:migrate
RAILS_ENV=production rails server -p 3001
```

## 🐛 Troubleshooting

### Error de conexión a PostgreSQL
```bash
# Verifica que PostgreSQL esté corriendo
# En Windows:
# Abrir "Servicios" y verificar que PostgreSQL esté iniciado

# Verifica credenciales en config/database.yml
```

### Gemas no instaladas
```bash
bundle install
```

### Base de datos no creada
```bash
rails db:create
rails db:migrate
```

## 📄 Licencia

MIT

## 👨‍💻 Contribución

1. Fork el proyecto
2. Crear una rama (`git checkout -b feature/nueva-funcionalidad`)
3. Commit cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crear Pull Request

## 📞 Contacto

Para soporte o consultas, contactar al equipo de desarrollo.
