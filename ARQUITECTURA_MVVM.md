# AssistFlow Backend - Ruby on Rails API

## 📋 Descripción
Backend API REST desarrollado en Ruby on Rails para el sistema AssistFlow de gestión de asistencias. Este proyecto utiliza el patrón **MVVM (Model-View-ViewModel)** adaptado para APIs.

## 🏗️ Arquitectura MVVM

### Estructura del Proyecto

```
app/
├── controllers/          # Capa de presentación (HTTP handling)
│   └── api/v1/          # Controladores API versión 1
├── models/              # Capa de datos (Model)
├── view_models/         # Lógica de presentación (ViewModel legacy)
├── services/            # Lógica de negocio (Business Logic Layer)
├── serializers/         # Transformación de datos para respuestas
├── interactors/         # Operaciones complejas multi-paso
├── validators/          # Validadores personalizados
└── concerns/            # Código reutilizable entre modelos
```

### Capas de la Arquitectura

#### 1. **Models** (Modelos)
- Representan las entidades de la base de datos
- Contienen validaciones básicas
- Definen relaciones entre entidades
- **Archivos**: `app/models/*.rb`

**Ejemplo:**
```ruby
class Employee < ApplicationRecord
  belongs_to :company
  has_many :attendance_records
  
  validates :name, presence: true
  validates :dni, uniqueness: true
end
```

#### 2. **Services** (Servicios)
- **Propósito**: Contienen la lógica de negocio
- Operaciones que involucran múltiples modelos
- Validaciones complejas de negocio
- **Ubicación**: `app/services/`

**Ejemplos:**
- `AuthenticationService`: Manejo de autenticación
- `AttendanceService`: Lógica de registros de asistencia
- `EmployeeService`: Gestión de empleados
- `NotificationService`: Sistema de notificaciones

#### 3. **Serializers** (Serializadores)
- **Propósito**: Transformar modelos en formato JSON
- Controlan qué datos se exponen en la API
- Diferentes vistas (summary, detailed, auth)
- **Ubicación**: `app/serializers/`

**Ejemplo:**
```ruby
class EmployeeSerializer
  def summary
    { id: employee.id, name: employee.name }
  end
  
  def detailed
    summary.merge(company: employee.company.name)
  end
end
```

#### 4. **Controllers** (Controladores)
- **Propósito**: Capa delgada de HTTP
- Manejan requests/responses
- Delegan lógica a Services
- **Ubicación**: `app/controllers/api/v1/`

**Principio**: Controllers deben ser DELGADOS
```ruby
def create
  result = EmployeeService.create_employee(params, current_user)
  
  if result[:success]
    render_success(result)
  else
    render_bad_request(result[:errors])
  end
end
```

#### 5. **Interactors** (Interactores)
- **Propósito**: Operaciones complejas multi-paso
- Transacciones que involucran múltiples servicios
- Patrón Command
- **Ubicación**: `app/interactors/`

**Ejemplo:**
```ruby
class CreateCompanyInteractor
  def call(company_params, location_params)
    # 1. Crear empresa
    # 2. Vincular perfil
    # 3. Crear ubicación
    # 4. Enviar notificación
  end
end
```

#### 6. **Validators** (Validadores)
- **Propósito**: Validaciones personalizadas complejas
- Reutilizables entre modelos
- **Ubicación**: `app/validators/`

## 🔑 Características Principales

### Autenticación JWT
- Sistema dual: Admin y Empleados
- Tokens con expiración configurable
- Middleware de autenticación en `BaseController`

### Gestión de Asistencias
- Check-in, Lunch Start/End, Check-out
- Validación de ubicación GPS
- Cálculo automático de tardanzas
- Estadísticas mensuales

### Sistema de Notificaciones
- Notificaciones polimórficas
- Para empleados y administradores
- Marcado de lectura

### Geolocalización
- Validación de asistencias por ubicación
- Radio de cobertura configurable
- Múltiples ubicaciones por empresa

## 📦 Modelos Principales

### Company (Empresa)
- Configuración de horarios
- Ubicaciones de trabajo
- Empleados asociados

### Employee (Empleado)
- Autenticación con PIN y contraseña
- Registro de asistencias
- Cálculo de nómina

### AttendanceRecord (Registro de Asistencia)
- Tipos: check_in, lunch_start, lunch_end, check_out
- Geolocalización
- Cálculo de tardanzas

### Profile (Perfil Admin)
- Administradores del sistema
- Gestión de empresas

## 🚀 Endpoints API

### Autenticación
```
POST   /api/v1/auth/register          # Registro de admin
POST   /api/v1/auth/admin/login       # Login admin
POST   /api/v1/auth/employee/login    # Login empleado
GET    /api/v1/auth/me                # Usuario actual
GET    /api/v1/auth/companies         # Lista de empresas
```

### Empleados
```
GET    /api/v1/employees              # Lista empleados
POST   /api/v1/employees              # Crear empleado
GET    /api/v1/employees/:id          # Ver empleado
PATCH  /api/v1/employees/:id          # Actualizar empleado
DELETE /api/v1/employees/:id          # Desactivar empleado
POST   /api/v1/employees/:id/reset_credentials  # Reset PIN/Password
```

### Asistencias
```
POST   /api/v1/attendance_records                      # Registrar asistencia
GET    /api/v1/attendance_records/today                # Asistencia de hoy
GET    /api/v1/attendance_records/employee/:id         # Por empleado
GET    /api/v1/attendance_records/company/:id/daily    # Reporte diario
GET    /api/v1/attendance_records/stats/:id            # Estadísticas
```

### Empresas
```
GET    /api/v1/companies/:id                # Ver empresa
POST   /api/v1/companies                    # Crear empresa
PATCH  /api/v1/companies/:id                # Actualizar empresa
GET    /api/v1/companies/:id/locations      # Ubicaciones
POST   /api/v1/companies/:id/locations      # Crear ubicación
```

### Notificaciones
```
GET    /api/v1/notifications                    # Lista notificaciones
GET    /api/v1/notifications/unread_count      # Contador no leídas
PATCH  /api/v1/notifications/:id/mark_read     # Marcar leída
PATCH  /api/v1/notifications/mark_all_read     # Marcar todas
```

## 🔧 Configuración

### Variables de Entorno (.env)
```env
# Database
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=postgres

# JWT
JWT_SECRET_KEY=your-secret-key-min-32-chars
JWT_EXPIRATION_HOURS=24

# CORS
CORS_ORIGINS=http://localhost:5173,http://localhost:3000

# Server
PORT=3000
RAILS_ENV=development
```

### Instalación

```bash
# 1. Instalar dependencias
bundle install

# 2. Configurar base de datos
rails db:create
rails db:migrate
rails db:seed

# 3. Iniciar servidor
rails server
```

## 📚 Guía de Desarrollo

### Crear un Nuevo Endpoint

1. **Crear Service** (Lógica de negocio)
```ruby
# app/services/my_service.rb
class MyService
  def execute(params)
    # Lógica aquí
    { success: true, data: result }
  end
end
```

2. **Crear Serializer** (Formato de respuesta)
```ruby
# app/serializers/my_serializer.rb
class MySerializer
  def as_json
    { id: object.id, name: object.name }
  end
end
```

3. **Actualizar Controller** (HTTP handling)
```ruby
# app/controllers/api/v1/my_controller.rb
def action
  result = MyService.new.execute(params)
  
  if result[:success]
    render_success(result[:data])
  else
    render_bad_request(result[:errors])
  end
end
```

### Mejores Prácticas

#### ✅ DO (Hacer)
- Mantener controladores delgados
- Lógica de negocio en Services
- Usar Serializers para respuestas
- Validar en múltiples capas
- Usar transacciones para operaciones complejas

#### ❌ DON'T (No hacer)
- Lógica de negocio en controladores
- Queries complejos en vistas
- Exponer todos los atributos del modelo
- Saltarse validaciones
- Duplicar código

## 🧪 Testing

```bash
# Ejecutar tests
rspec

# Con cobertura
COVERAGE=true rspec
```

## 📖 Patrón MVVM Explicado

### Flujo de Datos

```
Request → Controller → Service → Model → Database
                ↓         ↓
           Serializer ← ViewModel (legacy)
                ↓
           Response (JSON)
```

### Responsabilidades

| Capa | Responsabilidad | Ejemplo |
|------|----------------|---------|
| **Controller** | HTTP handling | Recibir params, retornar JSON |
| **Service** | Business logic | Validar, calcular, coordinar |
| **Model** | Data access | CRUD, relaciones, validaciones |
| **Serializer** | Data transformation | Formatear JSON response |
| **Interactor** | Complex operations | Multi-step workflows |

## 🎓 Conceptos para Programación Móvil

### Autenticación Stateless
- JWT tokens para cada request
- No sesiones en servidor
- Ideal para apps móviles

### API RESTful
- Recursos bien definidos
- Verbos HTTP semánticos
- Respuestas consistentes

### Geolocalización
- Validación por GPS
- Cálculo de distancias
- Radio de cobertura

### Optimización Móvil
- Paginación de resultados
- Filtros eficientes
- Respuestas compactas

## 📝 Notas del Curso

Este proyecto está diseñado para enseñar:

1. **Arquitectura de Software**: Patrón MVVM en backend
2. **API Design**: RESTful principles
3. **Security**: JWT, autenticación, autorización
4. **Database Design**: Relaciones, migraciones
5. **Business Logic**: Services, Interactors
6. **Best Practices**: SOLID, DRY, Clean Code

## 🤝 Contribución

Para agregar nuevas funcionalidades, sigue la estructura MVVM:
1. Modelo de datos
2. Service para lógica
3. Serializer para respuestas
4. Controller para HTTP
5. Tests

## 📄 Licencia

Proyecto educativo para curso de Programación Móvil.
