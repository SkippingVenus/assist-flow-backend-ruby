# Ejemplos de Uso - AssistFlow Backend

## 📱 Integración con Flutter

### Setup del Cliente HTTP en Flutter

```dart
// lib/services/api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api/v1';
  String? _token;

  // Guardar token después del login
  void setToken(String token) {
    _token = token;
  }

  // Headers con autenticación
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // GET request
  Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // POST request
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: json.encode(body),
    );
    return _handleResponse(response);
  }

  // Manejar respuesta
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception(json.decode(response.body)['error']);
    }
  }
}
```

### Ejemplo: Login de Empleado

```dart
// lib/services/auth_service.dart
class AuthService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> employeeLogin({
    required String companyId,
    required String dni,
    required String pin,
  }) async {
    try {
      final response = await _api.post('/auth/employee/login', {
        'company_id': companyId,
        'dni': dni,
        'pin': pin,
      });

      // Guardar token
      _api.setToken(response['token']);
      
      return {
        'success': true,
        'user': response['user'],
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
```

### Ejemplo: Registrar Asistencia con GPS

```dart
// lib/services/attendance_service.dart
import 'package:geolocator/geolocator.dart';

class AttendanceService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> checkIn() async {
    try {
      // 1. Obtener ubicación actual
      Position position = await Geolocator.getCurrentPosition();

      // 2. Enviar al backend
      final response = await _api.post('/attendance_records', {
        'attendance_type': 'check_in',
        'latitude': position.latitude,
        'longitude': position.longitude,
      });

      return {
        'success': true,
        'record': response['record'],
        'message': response['message'],
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> getTodaySummary() async {
    try {
      final response = await _api.get('/attendance_records/today');
      return {
        'success': true,
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
```

## 🔧 Ejemplos de Uso del Backend (Ruby)

### 1. Crear Empleado desde Consola Rails

```ruby
# rails console

# Buscar la empresa
company = Company.first

# Crear empleado usando el Service
result = EmployeeService.create_employee(
  {
    name: "Carlos Rodríguez",
    dni: "98765432",
    job_position: "Backend Developer",
    hourly_salary: 30.0,
    hourly_deduction: 5.0
  },
  company.profiles.first # admin profile
)

if result[:success]
  puts "Empleado creado:"
  puts "PIN: #{result[:credentials][:pin]}"
  puts "Password: #{result[:credentials][:password]}"
else
  puts "Error: #{result[:errors]}"
end
```

### 2. Simular Registro de Asistencia

```ruby
# rails console

# Buscar empleado
employee = Employee.find_by(dni: "98765432")

# Registrar entrada
service = AttendanceService.new(employee)
result = service.record_attendance(
  attendance_type: 'check_in',
  latitude: -12.0464,
  longitude: -77.0428
)

if result[:success]
  puts "Asistencia registrada:"
  puts result[:record]
else
  puts "Error: #{result[:error]}"
end
```

### 3. Obtener Estadísticas Mensuales

```ruby
# rails console

employee = Employee.find_by(dni: "98765432")
service = AttendanceService.new(employee)

stats = service.monthly_stats(1, 2025) # Enero 2025

puts "Estadísticas de Enero 2025:"
puts "Total días: #{stats[:total_days]}"
puts "Días tarde: #{stats[:late_days]}"
puts "Días a tiempo: #{stats[:on_time_days]}"
puts "Total minutos tarde: #{stats[:total_late_minutes]}"
puts "Promedio minutos tarde: #{stats[:average_late_minutes]}"
```

### 4. Generar Reporte Diario de Empresa

```ruby
# rails console

company = Company.first
report = AttendanceService.company_daily_report(company, Date.today)

puts "Reporte del #{report[:date]}:"
puts "Total empleados: #{report[:total_employees]}"
puts "Presentes: #{report[:present]}"
puts "Ausentes: #{report[:absent]}"
puts "Tardanzas: #{report[:late]}"

# Ver detalles por empleado
report[:employees].each do |emp_data|
  employee = emp_data[:employee]
  puts "\n#{employee[:name]}:"
  puts "  Presente: #{emp_data[:is_present] ? 'Sí' : 'No'}"
  puts "  Tarde: #{emp_data[:is_late] ? 'Sí' : 'No'}"
end
```

## 🧪 Ejemplos de Testing (RSpec)

### Test de Service

```ruby
# spec/services/authentication_service_spec.rb
require 'rails_helper'

RSpec.describe AuthenticationService do
  describe '.employee_login' do
    let(:company) { create(:company) }
    let(:employee) { create(:employee, company: company, dni: '12345678') }

    context 'with valid credentials' do
      it 'returns success with token' do
        result = AuthenticationService.employee_login(
          company_id: company.id,
          dni: '12345678',
          pin: employee.pin # assuming you stored pin in factory
        )

        expect(result[:success]).to be true
        expect(result[:token]).to be_present
        expect(result[:user][:id]).to eq(employee.id)
      end
    end

    context 'with invalid credentials' do
      it 'returns error' do
        result = AuthenticationService.employee_login(
          company_id: company.id,
          dni: '12345678',
          pin: 'wrong_pin'
        )

        expect(result[:success]).to be false
        expect(result[:error]).to eq('Credenciales inválidas')
      end
    end
  end
end
```

### Test de Controller

```ruby
# spec/requests/api/v1/employees_spec.rb
require 'rails_helper'

RSpec.describe 'Api::V1::Employees', type: :request do
  let(:company) { create(:company) }
  let(:admin) { create(:profile, company: company) }
  let(:token) { JsonWebToken.encode(id: admin.id, type: 'admin') }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  describe 'GET /api/v1/employees' do
    it 'returns list of employees' do
      create_list(:employee, 3, company: company)

      get '/api/v1/employees', headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['employees'].length).to eq(3)
    end
  end

  describe 'POST /api/v1/employees' do
    it 'creates employee with credentials' do
      employee_params = {
        employee: {
          name: 'Test Employee',
          dni: '12345678',
          job_position: 'Developer'
        }
      }

      post '/api/v1/employees', params: employee_params, headers: headers

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['credentials']).to be_present
      expect(json['credentials']['pin']).to be_present
      expect(json['credentials']['password']).to be_present
    end
  end
end
```

## 🎯 Casos de Uso Comunes

### Caso 1: Flujo Completo de Registro de Asistencia

```ruby
# 1. Empleado abre la app
employee = Employee.find_by(dni: "12345678")

# 2. App obtiene ubicación GPS
latitude = -12.0464
longitude = -77.0428

# 3. App envía request de check-in
service = AttendanceService.new(employee)
result = service.record_attendance(
  attendance_type: 'check_in',
  latitude: latitude,
  longitude: longitude
)

# 4. Backend valida ubicación
# 5. Backend calcula si llegó tarde
# 6. Backend crea registro
# 7. Backend envía notificación si llegó tarde
# 8. Backend retorna resultado a la app

if result[:success]
  # App muestra confirmación
  puts "Entrada registrada: #{result[:record][:timestamp]}"
  puts "Llegaste tarde: #{result[:record][:is_late]}"
  if result[:record][:is_late]
    puts "Minutos tarde: #{result[:record][:minutes_late]}"
  end
else
  # App muestra error
  puts "Error: #{result[:error]}"
end
```

### Caso 2: Admin Crea Empleado y Comparte Credenciales

```ruby
# 1. Admin crea empleado
result = EmployeeService.create_employee(
  {
    name: "Nuevo Empleado",
    dni: "11223344",
    job_position: "Analista",
    hourly_salary: 25.0
  },
  current_admin # perfil del admin
)

if result[:success]
  employee = result[:employee]
  credentials = result[:credentials]
  
  # 2. Admin puede enviar credenciales por email o mostrar en pantalla
  puts "Empleado creado exitosamente"
  puts "Nombre: #{employee.name}"
  puts "DNI: #{employee.dni}"
  puts "\nCredenciales de acceso:"
  puts "PIN: #{credentials[:pin]}"
  puts "Contraseña: #{credentials[:password]}"
  puts "\n⚠️ Guarda estas credenciales, no se pueden recuperar"
end
```

### Caso 3: Resetear Credenciales de Empleado

```ruby
# Cuando un empleado olvida su PIN o contraseña
employee = Employee.find_by(dni: "11223344")
service = EmployeeService.new(employee)

# Resetear solo PIN
result = service.reset_credentials(reset_pin: true, reset_password: false)

if result[:success]
  puts "Nuevo PIN: #{result[:credentials][:pin]}"
end

# O resetear ambos
result = service.reset_credentials(reset_pin: true, reset_password: true)

if result[:success]
  puts "Nuevo PIN: #{result[:credentials][:pin]}"
  puts "Nueva contraseña: #{result[:credentials][:password]}"
end
```

## 📊 Consultas Útiles en Rails Console

### Ver todas las asistencias de hoy

```ruby
today_records = AttendanceRecord.where(
  'DATE(timestamp) = ?', 
  Date.today
).includes(:employee)

today_records.each do |record|
  puts "#{record.employee.name} - #{record.attendance_type} - #{record.timestamp.strftime('%H:%M')}"
end
```

### Empleados que llegaron tarde hoy

```ruby
late_today = AttendanceRecord.where(
  'DATE(timestamp) = ? AND attendance_type = ? AND is_late = ?',
  Date.today,
  'check_in',
  true
).includes(:employee)

puts "Empleados que llegaron tarde hoy:"
late_today.each do |record|
  puts "#{record.employee.name} - #{record.minutes_late} minutos tarde"
end
```

### Estadísticas de la empresa

```ruby
company = Company.first
employees = company.employees.active

puts "Empresa: #{company.name}"
puts "Total empleados activos: #{employees.count}"

# Asistencia de hoy
today_checkins = AttendanceRecord.where(
  employee_id: employees.pluck(:id),
  attendance_type: 'check_in'
).where('DATE(timestamp) = ?', Date.today)

puts "Presentes hoy: #{today_checkins.count}"
puts "Tardanzas hoy: #{today_checkins.where(is_late: true).count}"
```

## 🔐 Ejemplos de Seguridad

### Validar Token JWT

```ruby
# En un controller o service
def validate_token(token)
  decoded = JsonWebToken.decode(token)
  
  if decoded
    user_type = decoded[:type]
    user_id = decoded[:id]
    
    if user_type == 'employee'
      Employee.find_by(id: user_id, is_active: true)
    elsif user_type == 'admin'
      Profile.find_by(id: user_id)
    end
  else
    nil
  end
end
```

### Verificar Permisos

```ruby
# En un controller
def authorize_employee_access(employee)
  if current_user_type == 'admin'
    # Admin solo puede ver empleados de su empresa
    return false if employee.company_id != current_user.company_id
  elsif current_user_type == 'employee'
    # Empleado solo puede ver su propia información
    return false if employee.id != current_user.id
  end
  
  true
end
```

## 📱 Respuestas JSON de Ejemplo

### Success: Login Empleado
```json
{
  "message": "Login exitoso",
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Juan Pérez",
    "dni": "12345678",
    "job_position": "Developer",
    "company_id": "660e8400-e29b-41d4-a716-446655440000"
  }
}
```

### Success: Registrar Asistencia
```json
{
  "message": "Asistencia registrada exitosamente",
  "record": {
    "id": "770e8400-e29b-41d4-a716-446655440000",
    "attendance_type": "check_in",
    "timestamp": "2025-01-10T08:05:30.000Z",
    "is_late": true,
    "minutes_late": 5
  }
}
```

### Error: Credenciales Inválidas
```json
{
  "error": "Credenciales inválidas"
}
```

### Error: Validación
```json
{
  "errors": [
    "Name can't be blank",
    "DNI has already been taken"
  ]
}
```

## 🎓 Tips para el Curso

### 1. Debugging con Byebug

```ruby
# Agregar en cualquier parte del código
def some_method
  byebug # El código se detendrá aquí
  # Puedes inspeccionar variables, ejecutar código, etc.
end
```

### 2. Ver SQL Queries Generadas

```ruby
# En rails console
ActiveRecord::Base.logger = Logger.new(STDOUT)

# Ahora todas las queries se mostrarán
Employee.where(is_active: true).to_a
```

### 3. Benchmarking

```ruby
require 'benchmark'

time = Benchmark.measure do
  AttendanceService.company_daily_report(company, Date.today)
end

puts "Tiempo de ejecución: #{time.real} segundos"
```

### 4. Usar Pry para Debugging Avanzado

```ruby
# Gemfile
gem 'pry-rails'

# Uso
binding.pry # Similar a byebug pero más potente
```
