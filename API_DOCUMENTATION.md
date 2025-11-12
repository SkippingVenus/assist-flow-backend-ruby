# API Documentation - AssistFlow

## 🌐 Base URL
```
http://localhost:3000/api/v1
```

## 🔑 Autenticación

Todas las rutas (excepto registro y login) requieren un token JWT en el header:

```
Authorization: Bearer <token>
```

## 📋 Respuestas Estándar

### Success Response
```json
{
  "data": { ... },
  "message": "Success message"
}
```

### Error Response
```json
{
  "error": "Error message"
}
```

o

```json
{
  "errors": ["Error 1", "Error 2"]
}
```

## 🔐 Autenticación

### Registro de Admin
```
POST /auth/register
```

**Body:**
```json
{
  "profile": {
    "email": "admin@company.com",
    "password": "securepass123",
    "full_name": "John Doe"
  },
  "company": {
    "name": "Mi Empresa",
    "expected_start_time": "08:00:00",
    "expected_end_time": "17:00:00",
    "lunch_start_time": "12:00:00",
    "lunch_end_time": "13:00:00"
  }
}
```

**Response 201:**
```json
{
  "message": "Registro exitoso",
  "token": "eyJhbGc...",
  "user": {
    "id": "uuid",
    "email": "admin@company.com",
    "full_name": "John Doe",
    "company_id": "uuid"
  }
}
```

---

### Login Admin
```
POST /auth/admin/login
```

**Body:**
```json
{
  "email": "admin@company.com",
  "password": "securepass123"
}
```

**Response 200:**
```json
{
  "message": "Login exitoso",
  "token": "eyJhbGc...",
  "user": {
    "id": "uuid",
    "email": "admin@company.com",
    "full_name": "John Doe",
    "company_id": "uuid"
  }
}
```

---

### Login Empleado
```
POST /auth/employee/login
```

**Body:**
```json
{
  "company_id": "uuid",
  "dni": "12345678",
  "pin": "1234"
}
```

**Response 200:**
```json
{
  "message": "Login exitoso",
  "token": "eyJhbGc...",
  "user": {
    "id": "uuid",
    "name": "Juan Pérez",
    "dni": "12345678",
    "job_position": "Developer",
    "company_id": "uuid"
  }
}
```

---

### Obtener Usuario Actual
```
GET /auth/me
Authorization: Bearer <token>
```

**Response 200:**
```json
{
  "user_type": "employee",
  "user": {
    "id": "uuid",
    "name": "Juan Pérez",
    "dni": "12345678",
    "job_position": "Developer",
    "company_id": "uuid"
  }
}
```

---

### Listar Empresas
```
GET /auth/companies
```

**Response 200:**
```json
{
  "companies": [
    {
      "id": "uuid",
      "name": "Mi Empresa"
    }
  ]
}
```

---

## 👥 Empleados

### Listar Empleados
```
GET /employees
Authorization: Bearer <admin-token>
```

**Query Params:**
- `is_active` (boolean): Filtrar por estado
- `search` (string): Buscar por nombre o DNI

**Response 200:**
```json
{
  "employees": [
    {
      "id": "uuid",
      "name": "Juan Pérez",
      "dni": "12345678",
      "job_position": "Developer",
      "is_active": true
    }
  ]
}
```

---

### Ver Empleado
```
GET /employees/:id
Authorization: Bearer <token>
```

**Response 200:**
```json
{
  "employee": {
    "id": "uuid",
    "name": "Juan Pérez",
    "dni": "12345678",
    "job_position": "Developer",
    "hourly_salary": 25.50,
    "hourly_deduction": 5.00,
    "late_count": 3,
    "is_active": true,
    "company_id": "uuid",
    "company": {
      "id": "uuid",
      "name": "Mi Empresa"
    },
    "created_at": "2025-01-01T10:00:00Z",
    "updated_at": "2025-01-05T15:30:00Z"
  }
}
```

---

### Crear Empleado
```
POST /employees
Authorization: Bearer <admin-token>
```

**Body:**
```json
{
  "employee": {
    "name": "María García",
    "dni": "87654321",
    "job_position": "Designer",
    "hourly_salary": 30.00,
    "hourly_deduction": 6.00
  }
}
```

**Response 201:**
```json
{
  "message": "Empleado creado exitosamente",
  "employee": {
    "id": "uuid",
    "name": "María García",
    "dni": "87654321",
    "job_position": "Designer",
    "hourly_salary": 30.00,
    "hourly_deduction": 6.00,
    "late_count": 0,
    "is_active": true
  },
  "credentials": {
    "pin": "5678",
    "password": "abc12345"
  }
}
```

---

### Actualizar Empleado
```
PATCH /employees/:id
Authorization: Bearer <admin-token>
```

**Body:**
```json
{
  "employee": {
    "job_position": "Senior Designer",
    "hourly_salary": 35.00
  }
}
```

**Response 200:**
```json
{
  "message": "Empleado actualizado exitosamente",
  "employee": { ... }
}
```

---

### Desactivar Empleado
```
DELETE /employees/:id
Authorization: Bearer <admin-token>
```

**Response 200:**
```json
{
  "message": "Empleado desactivado exitosamente"
}
```

---

### Resetear Credenciales
```
POST /employees/:id/reset_credentials
Authorization: Bearer <admin-token>
```

**Body:**
```json
{
  "reset_pin": true,
  "reset_password": true
}
```

**Response 200:**
```json
{
  "message": "Credenciales reseteadas exitosamente",
  "employee": {
    "id": "uuid",
    "name": "Juan Pérez",
    "dni": "12345678"
  },
  "new_credentials": {
    "pin": "9876",
    "password": "xyz98765"
  }
}
```

---

## ⏰ Asistencias

### Registrar Asistencia
```
POST /attendance_records
Authorization: Bearer <employee-token>
```

**Body:**
```json
{
  "attendance_type": "check_in",
  "latitude": -12.0464,
  "longitude": -77.0428
}
```

**Tipos válidos:**
- `check_in`: Entrada
- `lunch_start`: Inicio de almuerzo
- `lunch_end`: Fin de almuerzo
- `check_out`: Salida

**Response 201:**
```json
{
  "message": "Asistencia registrada exitosamente",
  "record": {
    "id": "uuid",
    "attendance_type": "check_in",
    "timestamp": "2025-01-10T08:05:00Z",
    "is_late": true,
    "minutes_late": 5
  }
}
```

**Error 422:**
```json
{
  "error": "Ya registraste entrada hoy"
}
```

---

### Asistencia de Hoy
```
GET /attendance_records/today
Authorization: Bearer <employee-token>
```

**Response 200:**
```json
{
  "date": "2025-01-10",
  "check_in": {
    "id": "uuid",
    "attendance_type": "check_in",
    "timestamp": "2025-01-10T08:05:00Z",
    "is_late": true,
    "minutes_late": 5
  },
  "lunch_start": null,
  "lunch_end": null,
  "check_out": null,
  "total_hours": 0
}
```

---

### Asistencias por Empleado
```
GET /attendance_records/employee/:employee_id
Authorization: Bearer <token>
```

**Query Params:**
- `start_date` (date): Fecha inicio
- `end_date` (date): Fecha fin
- `limit` (integer): Límite de resultados (default: 100)

**Response 200:**
```json
{
  "records": [
    {
      "id": "uuid",
      "employee_id": "uuid",
      "employee_name": "Juan Pérez",
      "attendance_type": "check_in",
      "timestamp": "2025-01-10T08:05:00Z",
      "latitude": -12.0464,
      "longitude": -77.0428,
      "is_late": true,
      "minutes_late": 5,
      "notes": null,
      "created_at": "2025-01-10T08:05:00Z"
    }
  ]
}
```

---

### Reporte Diario de Empresa
```
GET /attendance_records/company/:company_id/daily
Authorization: Bearer <admin-token>
```

**Query Params:**
- `date` (date): Fecha del reporte (default: hoy)

**Response 200:**
```json
{
  "date": "2025-01-10",
  "company": {
    "id": "uuid",
    "name": "Mi Empresa"
  },
  "total_employees": 10,
  "present": 8,
  "absent": 2,
  "late": 3,
  "employees": [
    {
      "employee": {
        "id": "uuid",
        "name": "Juan Pérez",
        "dni": "12345678"
      },
      "check_in": { ... },
      "check_out": null,
      "is_present": true,
      "is_late": true
    }
  ]
}
```

---

### Estadísticas Mensuales
```
GET /attendance_records/stats/:employee_id
Authorization: Bearer <token>
```

**Query Params:**
- `month` (integer): Mes (1-12)
- `year` (integer): Año

**Response 200:**
```json
{
  "month": 1,
  "year": 2025,
  "total_days": 20,
  "late_days": 5,
  "on_time_days": 15,
  "total_late_minutes": 75,
  "average_late_minutes": 15.0
}
```

---

## 🏢 Empresas

### Ver Empresa
```
GET /companies/:id
Authorization: Bearer <admin-token>
```

**Response 200:**
```json
{
  "company": {
    "id": "uuid",
    "name": "Mi Empresa",
    "expected_start_time": "08:00:00",
    "expected_end_time": "17:00:00",
    "lunch_start_time": "12:00:00",
    "lunch_end_time": "13:00:00",
    "locations": [
      {
        "id": "uuid",
        "name": "Oficina Principal",
        "address": "Av. Principal 123",
        "latitude": -12.0464,
        "longitude": -77.0428,
        "radius_meters": 100,
        "is_active": true
      }
    ],
    "employees_count": 10,
    "created_at": "2025-01-01T10:00:00Z",
    "updated_at": "2025-01-05T15:30:00Z"
  }
}
```

---

### Actualizar Empresa
```
PATCH /companies/:id
Authorization: Bearer <admin-token>
```

**Body:**
```json
{
  "company": {
    "expected_start_time": "08:30:00",
    "expected_end_time": "17:30:00"
  }
}
```

**Response 200:**
```json
{
  "message": "Empresa actualizada exitosamente",
  "company": { ... }
}
```

---

### Listar Ubicaciones
```
GET /companies/:id/locations
Authorization: Bearer <admin-token>
```

**Response 200:**
```json
{
  "locations": [
    {
      "id": "uuid",
      "name": "Oficina Principal",
      "address": "Av. Principal 123",
      "latitude": -12.0464,
      "longitude": -77.0428,
      "radius_meters": 100,
      "is_active": true,
      "created_at": "2025-01-01T10:00:00Z",
      "updated_at": "2025-01-05T15:30:00Z"
    }
  ]
}
```

---

### Crear Ubicación
```
POST /companies/:id/locations
Authorization: Bearer <admin-token>
```

**Body:**
```json
{
  "location": {
    "name": "Sucursal Norte",
    "address": "Av. Norte 456",
    "latitude": -12.0500,
    "longitude": -77.0500,
    "radius_meters": 150
  }
}
```

**Response 201:**
```json
{
  "message": "Ubicación creada exitosamente",
  "location": { ... }
}
```

---

## 🔔 Notificaciones

### Listar Notificaciones
```
GET /notifications
Authorization: Bearer <token>
```

**Query Params:**
- `limit` (integer): Límite de resultados (default: 50)

**Response 200:**
```json
{
  "notifications": [
    {
      "id": "uuid",
      "title": "Llegada tardía registrada",
      "message": "Llegaste 5 minutos tarde el 10/01/2025",
      "notification_type": "late_arrival",
      "is_read": false,
      "created_at": "2025-01-10T08:05:00Z",
      "read_at": null
    }
  ]
}
```

---

### Contador No Leídas
```
GET /notifications/unread_count
Authorization: Bearer <token>
```

**Response 200:**
```json
{
  "unread_count": 3
}
```

---

### Marcar como Leída
```
PATCH /notifications/:id/mark_read
Authorization: Bearer <token>
```

**Response 200:**
```json
{
  "message": "Notificación marcada como leída"
}
```

---

### Marcar Todas como Leídas
```
PATCH /notifications/mark_all_read
Authorization: Bearer <token>
```

**Response 200:**
```json
{
  "message": "Todas las notificaciones marcadas como leídas"
}
```

---

## 📊 Códigos de Estado HTTP

| Código | Significado |
|--------|-------------|
| 200 | OK - Solicitud exitosa |
| 201 | Created - Recurso creado |
| 400 | Bad Request - Parámetros inválidos |
| 401 | Unauthorized - No autenticado |
| 403 | Forbidden - Sin permisos |
| 404 | Not Found - Recurso no encontrado |
| 422 | Unprocessable Entity - Validación fallida |
| 500 | Internal Server Error - Error del servidor |

---

## 🧪 Ejemplos con cURL

### Registro
```bash
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "profile": {
      "email": "admin@test.com",
      "password": "pass123",
      "full_name": "Test Admin"
    },
    "company": {
      "name": "Test Company"
    }
  }'
```

### Login Empleado
```bash
curl -X POST http://localhost:3000/api/v1/auth/employee/login \
  -H "Content-Type: application/json" \
  -d '{
    "company_id": "uuid",
    "dni": "12345678",
    "pin": "1234"
  }'
```

### Registrar Asistencia
```bash
curl -X POST http://localhost:3000/api/v1/attendance_records \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJhbGc..." \
  -d '{
    "attendance_type": "check_in",
    "latitude": -12.0464,
    "longitude": -77.0428
  }'
```
