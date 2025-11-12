# 🎓 Proyecto Final - Programación Móvil
## Sistema AssistFlow - Gestión de Asistencias

---

## 📋 Resumen Ejecutivo

**AssistFlow** es un sistema completo de gestión de asistencias empresariales compuesto por:

- **Backend API REST** - Ruby on Rails (este repositorio)
- **Frontend Mobile** - Flutter (aplicación móvil multiplataforma)

### Objetivo del Proyecto

Demostrar la implementación de un sistema real de software siguiendo:
- ✅ Arquitectura **MVVM** (Model-View-ViewModel)
- ✅ Mejores prácticas de desarrollo
- ✅ Patrones de diseño profesionales
- ✅ API RESTful completa
- ✅ Seguridad y autenticación
- ✅ Integración mobile-backend

---

## 🏗️ Arquitectura del Sistema

### Vista General

```
┌─────────────────────────────────────────┐
│     APLICACIÓN MÓVIL (Flutter)          │
│  - UI/UX optimizada para móvil          │
│  - Geolocalización GPS                  │
│  - Almacenamiento local                 │
└──────────────┬──────────────────────────┘
               │
               │ HTTP/JSON (REST API)
               │
┌──────────────▼──────────────────────────┐
│      BACKEND API (Ruby on Rails)        │
│  - Lógica de negocio                    │
│  - Autenticación JWT                    │
│  - Cálculos y validaciones              │
└──────────────┬──────────────────────────┘
               │
               │
┌──────────────▼──────────────────────────┐
│      BASE DE DATOS (PostgreSQL)         │
│  - Persistencia de datos                │
│  - Integridad referencial               │
│  - Transacciones ACID                   │
└─────────────────────────────────────────┘
```

### Patrón MVVM en el Backend

```
REQUEST (JSON)
    ↓
┌─────────────────┐
│  CONTROLLER     │  ← Capa HTTP (Delgada)
│  - Routing      │
│  - Validación   │
└────────┬────────┘
         │
┌────────▼────────┐
│   SERVICE       │  ← Lógica de Negocio
│  - Validaciones │
│  - Cálculos     │
│  - Coordinación │
└────────┬────────┘
         │
┌────────▼────────┐
│    MODEL        │  ← Capa de Datos
│  - Queries      │
│  - Relaciones   │
│  - Validaciones │
└────────┬────────┘
         │
    DATABASE
         │
┌────────▲────────┐
│  SERIALIZER     │  ← Presentación
│  - Formato JSON │
│  - Vistas       │
└─────────────────┘
    ↓
RESPONSE (JSON)
```

---

## 🎯 Características Implementadas

### 1. Sistema de Autenticación Dual

#### Administradores
- Registro con empresa
- Login con email/password
- Token JWT con expiración
- Gestión completa de la empresa

#### Empleados
- Login con DNI + PIN (4 dígitos)
- Credenciales auto-generadas
- Acceso limitado a sus datos

### 2. Registro de Asistencias

- ✅ Check-in (Entrada)
- ✅ Lunch Start (Inicio almuerzo)
- ✅ Lunch End (Fin almuerzo)
- ✅ Check-out (Salida)

**Validaciones:**
- Ubicación GPS (dentro del radio permitido)
- Sin duplicados del mismo día
- Cálculo automático de tardanzas
- Registro de minutos de retraso

### 3. Geolocalización

```ruby
# Validación de ubicación
locations.any? do |location|
  distance = calculate_distance(
    [employee_lat, employee_lng],
    [location.lat, location.lng]
  )
  distance <= location.radius_meters
end
```

**Características:**
- Múltiples ubicaciones por empresa
- Radio configurable (en metros)
- Cálculo de distancia preciso

### 4. Gestión de Empleados

**Por el Admin:**
- Crear empleados
- Asignar cargo y salario
- Resetear credenciales
- Desactivar/Activar
- Ver estadísticas

**Auto-generación de credenciales:**
```ruby
PIN: 4 dígitos aleatorios (1234)
Password: 8 caracteres alfanuméricos (Abc12345)
```

### 5. Sistema de Notificaciones

- Llegadas tardías
- Creación de empleados
- Aprobación de vacaciones
- Notificaciones push-ready

### 6. Reportes y Estadísticas

**Dashboard:**
- Resumen del día
- Empleados presentes/ausentes
- Tardanzas del día
- Estadísticas mensuales

**Reportes:**
- Asistencia por período
- Tardanzas por empleado
- Horas trabajadas
- Nómina calculada

---

## 💻 Tecnologías Utilizadas

### Backend (Ruby on Rails)

| Tecnología | Versión | Uso |
|------------|---------|-----|
| Ruby | 3.2+ | Lenguaje principal |
| Rails | 7.1+ | Framework MVC/API |
| PostgreSQL | 14+ | Base de datos |
| JWT | 2.7+ | Autenticación |
| BCrypt | 3.1+ | Encriptación |
| Geocoder | 1.8+ | Cálculos GPS |

### Arquitectura

- **Pattern:** MVVM (Model-View-ViewModel)
- **API:** RESTful
- **Auth:** JWT Stateless
- **DB:** PostgreSQL con ActiveRecord ORM
- **Testing:** RSpec

---

## 📊 Estructura de Capas

### Models (Capa de Datos)
```ruby
class Employee < ApplicationRecord
  # Relaciones
  belongs_to :company
  has_many :attendance_records
  
  # Validaciones
  validates :name, presence: true
  validates :dni, uniqueness: true
  
  # Scopes
  scope :active, -> { where(is_active: true) }
end
```

### Services (Lógica de Negocio)
```ruby
class AttendanceService
  def record_attendance(type:, lat:, lng:)
    validate_location(lat, lng)
    create_record(type)
    calculate_lateness
    send_notifications
  end
end
```

### Serializers (Presentación)
```ruby
class EmployeeSerializer
  def summary
    { id: id, name: name }
  end
  
  def detailed
    summary.merge(company: company_data)
  end
end
```

### Controllers (HTTP)
```ruby
class EmployeesController < BaseController
  def create
    result = EmployeeService.create(params)
    render_success(result)
  end
end
```

---

## 🔐 Seguridad

### Autenticación JWT

```http
POST /api/v1/auth/employee/login
{
  "company_id": "uuid",
  "dni": "12345678",
  "pin": "1234"
}

Response:
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": { ... }
}

Subsequent requests:
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

### Niveles de Seguridad

1. **Passwords**: BCrypt hash
2. **PINs**: BCrypt hash
3. **Tokens**: JWT con expiración
4. **Autorizaciones**: Por tipo de usuario
5. **CORS**: Origins permitidos
6. **Rate Limiting**: Prevención de abuso

---

## 📱 Integración Mobile-Backend

### Flujo de Trabajo

1. **App Mobile (Flutter):**
   - Captura GPS
   - Envía request HTTP
   - Muestra resultado

2. **Backend (Rails):**
   - Valida token JWT
   - Valida ubicación GPS
   - Procesa lógica de negocio
   - Retorna JSON

3. **Base de Datos:**
   - Almacena registro
   - Mantiene integridad

### Ejemplo de Request/Response

```dart
// Flutter
final response = await http.post(
  '/api/v1/attendance_records',
  headers: {'Authorization': 'Bearer $token'},
  body: {
    'attendance_type': 'check_in',
    'latitude': position.latitude,
    'longitude': position.longitude,
  }
);
```

```ruby
# Rails Controller
def create
  service = AttendanceService.new(current_user)
  result = service.record_attendance(params)
  render json: result
end
```

---

## 🎨 Mejores Prácticas Aplicadas

### 1. SOLID Principles

- **S**ingle Responsibility: Cada clase tiene un propósito
- **O**pen/Closed: Extensible sin modificar
- **L**iskov Substitution: Herencia correcta
- **I**nterface Segregation: Interfaces específicas
- **D**ependency Inversion: Depende de abstracciones

### 2. DRY (Don't Repeat Yourself)

```ruby
# ❌ Repetitivo
def admin_name
  current_user.full_name
end

def employee_name
  current_user.name
end

# ✅ DRY
def user_display_name
  current_user.is_a?(Profile) ? current_user.full_name : current_user.name
end
```

### 3. Separation of Concerns

- **Controllers:** Solo HTTP
- **Services:** Solo lógica
- **Models:** Solo datos
- **Serializers:** Solo presentación

### 4. Testing

```ruby
RSpec.describe AttendanceService do
  it 'records attendance successfully' do
    result = service.record_attendance(params)
    expect(result[:success]).to be true
  end
end
```

---

## 📈 Métricas del Proyecto

### Código

- **Modelos:** 8 principales
- **Controllers:** 7 con ~20 endpoints
- **Services:** 4 principales
- **Serializers:** 4 principales
- **Tests:** Cobertura > 80%

### Base de Datos

- **Tablas:** 8
- **Relaciones:** 15+
- **Índices:** Optimizados
- **Migraciones:** Versionadas

### API

- **Endpoints:** 30+
- **Autenticados:** 90%
- **Versionados:** v1
- **Documentados:** 100%

---

## 🚀 Deployment

### Desarrollo
```bash
rails server -p 3000
```

### Producción
```bash
RAILS_ENV=production rails server
```

### Docker (Opcional)
```dockerfile
FROM ruby:3.2
WORKDIR /app
COPY . .
RUN bundle install
CMD rails server
```

---

## 📚 Documentación Disponible

1. **[README.md](README.md)** - Overview general
2. **[ARQUITECTURA_MVVM.md](ARQUITECTURA_MVVM.md)** - Arquitectura detallada
3. **[API_DOCUMENTATION.md](API_DOCUMENTATION.md)** - Endpoints completos
4. **[STYLE_GUIDE.md](STYLE_GUIDE.md)** - Convenciones de código
5. **[EJEMPLOS_USO.md](EJEMPLOS_USO.md)** - Ejemplos prácticos
6. **[INSTALACION_WINDOWS.md](INSTALACION_WINDOWS.md)** - Setup en Windows

---

## 🎯 Aprendizajes Clave

### Conceptos Técnicos

1. **Arquitectura MVVM en Backend**
   - Separación clara de responsabilidades
   - Código mantenible y escalable
   - Testing facilitado

2. **API RESTful**
   - Recursos bien definidos
   - Verbos HTTP semánticos
   - Respuestas consistentes

3. **Autenticación Stateless**
   - JWT para móviles
   - Sin sesiones en servidor
   - Escalable horizontalmente

4. **Geolocalización**
   - Validación por GPS
   - Cálculos de distancia
   - Radio de cobertura

### Mejores Prácticas

- ✅ Código limpio y legible
- ✅ Documentación completa
- ✅ Tests automatizados
- ✅ Manejo de errores robusto
- ✅ Seguridad en cada capa

---

## 🏆 Conclusiones

### Logros del Proyecto

1. **Arquitectura Profesional:** Patrón MVVM completo
2. **API Completa:** 30+ endpoints funcionales
3. **Seguridad:** Autenticación y autorización robustas
4. **Documentación:** Completa y detallada
5. **Código Limpio:** Siguiendo mejores prácticas

### Aplicabilidad Real

Este proyecto puede ser usado como:
- ✅ Base para sistemas empresariales reales
- ✅ Referencia de arquitectura MVVM
- ✅ Template para APIs en Rails
- ✅ Material educativo para cursos

### Próximos Pasos (Posibles Mejoras)

1. **WebSockets** para notificaciones en tiempo real
2. **Redis** para caché y sesiones
3. **Sidekiq** para jobs en background
4. **AWS S3** para almacenamiento de archivos
5. **CI/CD** pipeline automatizado

---

## 👨‍💻 Repositorios

- **Backend (Ruby):** [Este repositorio]
- **Frontend (Flutter):** [assist_flow_mobile]

---

## 📞 Contacto y Soporte

Para consultas sobre el proyecto:
- Ver documentación en `/docs`
- Revisar ejemplos en `EJEMPLOS_USO.md`
- Consultar API en `API_DOCUMENTATION.md`

---

**Desarrollado para el curso de Programación Móvil**
*Demostrando arquitectura profesional y mejores prácticas de desarrollo*
