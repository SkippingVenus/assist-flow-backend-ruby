# Guía de Estilo - AssistFlow Backend

## 🎨 Convenciones de Código Ruby

### Nomenclatura

#### Clases y Módulos (PascalCase)
```ruby
class EmployeeService
class CreateCompanyInteractor
module Api::V1
```

#### Métodos y Variables (snake_case)
```ruby
def create_employee
def calculate_total_hours
attendance_type = 'check_in'
```

#### Constantes (SCREAMING_SNAKE_CASE)
```ruby
MAX_LATE_MINUTES = 30
DEFAULT_RADIUS_METERS = 100
```

### Estructura de Archivos

#### Services
```ruby
# app/services/nombre_service.rb
class NombreService
  attr_reader :object
  
  def initialize(object)
    @object = object
  end
  
  def execute(params)
    # Lógica aquí
    success_result(data)
  rescue => e
    error_result(e.message)
  end
  
  private
  
  def success_result(data)
    { success: true, data: data }
  end
  
  def error_result(message)
    { success: false, error: message }
  end
end
```

#### Serializers
```ruby
# app/serializers/nombre_serializer.rb
class NombreSerializer
  attr_reader :object
  
  def initialize(object)
    @object = object
  end
  
  def as_json(options = {})
    {
      id: object.id,
      # ... más campos
    }
  end
  
  def summary
    {
      id: object.id,
      name: object.name
    }
  end
  
  def detailed
    as_json.merge(
      # ... campos adicionales
    )
  end
end
```

#### Controllers
```ruby
# app/controllers/api/v1/nombre_controller.rb
module Api
  module V1
    class NombreController < BaseController
      before_action :set_object, only: [:show, :update, :destroy]
      before_action :authorize_access, only: [:update, :destroy]
      
      def index
        # Lista de recursos
        objects = Model.all
        serialized = objects.map { |obj| Serializer.new(obj).summary }
        render_success({ data: serialized })
      end
      
      def show
        serialized = Serializer.new(@object).detailed
        render_success({ data: serialized })
      end
      
      def create
        result = Service.execute(params)
        
        if result[:success]
          render_success(result, :created)
        else
          render_bad_request(result[:errors])
        end
      end
      
      private
      
      def set_object
        @object = Model.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_not_found
      end
      
      def authorize_access
        render_forbidden unless can_access?(@object)
      end
      
      def object_params
        params.require(:object).permit(:field1, :field2)
      end
    end
  end
end
```

## 📦 Organización de Código

### Orden en Models
```ruby
class Model < ApplicationRecord
  # 1. Includes y Extends
  include Searchable
  
  # 2. Constantes
  TYPES = %w[type1 type2]
  
  # 3. Relaciones
  belongs_to :parent
  has_many :children
  
  # 4. Validaciones
  validates :name, presence: true
  
  # 5. Callbacks
  before_save :do_something
  
  # 6. Scopes
  scope :active, -> { where(active: true) }
  
  # 7. Métodos de clase
  def self.class_method
  end
  
  # 8. Métodos de instancia (públicos)
  def instance_method
  end
  
  # 9. Métodos privados
  private
  
  def private_method
  end
end
```

### Orden en Controllers
```ruby
class Controller < BaseController
  # 1. Before/After actions
  before_action :authenticate
  before_action :set_object, only: [:show]
  
  # 2. Acciones CRUD (orden RESTful)
  def index
  end
  
  def show
  end
  
  def create
  end
  
  def update
  end
  
  def destroy
  end
  
  # 3. Acciones personalizadas
  def custom_action
  end
  
  # 4. Métodos privados
  private
  
  def set_object
  end
  
  def object_params
  end
end
```

## 🔍 Patrones de Diseño

### Service Pattern
```ruby
# Bueno ✅
class ProcessPaymentService
  def initialize(employee, month, year)
    @employee = employee
    @month = month
    @year = year
  end
  
  def execute
    calculate_hours
    calculate_deductions
    generate_payslip
    
    { success: true, payslip: @payslip }
  rescue => e
    { success: false, error: e.message }
  end
  
  private
  
  def calculate_hours
    # ...
  end
end

# Uso
result = ProcessPaymentService.new(employee, 1, 2025).execute
```

### Repository Pattern (Opcional)
```ruby
class EmployeeRepository
  def self.active_by_company(company_id)
    Employee.where(company_id: company_id, is_active: true)
  end
  
  def self.search(query, company_id)
    active_by_company(company_id)
      .where("name ILIKE :q OR dni ILIKE :q", q: "%#{query}%")
  end
end
```

### Query Object Pattern
```ruby
class AttendanceQuery
  def initialize(relation = AttendanceRecord.all)
    @relation = relation
  end
  
  def by_employee(employee_id)
    @relation = @relation.where(employee_id: employee_id)
    self
  end
  
  def by_date_range(start_date, end_date)
    @relation = @relation.where(timestamp: start_date..end_date)
    self
  end
  
  def late_only
    @relation = @relation.where(is_late: true)
    self
  end
  
  def results
    @relation
  end
end

# Uso
query = AttendanceQuery.new
        .by_employee(employee_id)
        .by_date_range(start_date, end_date)
        .late_only
        .results
```

## 🎯 Mejores Prácticas

### DRY (Don't Repeat Yourself)
```ruby
# Malo ❌
def admin_name
  current_user.is_a?(Profile) ? current_user.full_name : current_user.name
end

def employee_name
  current_user.is_a?(Profile) ? current_user.full_name : current_user.name
end

# Bueno ✅
def user_display_name
  current_user.is_a?(Profile) ? current_user.full_name : current_user.name
end
```

### Single Responsibility Principle
```ruby
# Malo ❌
class Employee
  def process_attendance_and_send_notification
    # Registrar asistencia
    # Calcular tardanza
    # Enviar notificación
    # Actualizar estadísticas
  end
end

# Bueno ✅
class AttendanceService
  def record_attendance(params)
    record = create_record(params)
    calculate_lateness(record)
    NotificationService.send_if_late(record)
    StatisticsService.update(record)
  end
end
```

### Dependency Injection
```ruby
# Bueno ✅
class PayrollCalculator
  def initialize(employee, calculator: SalaryCalculator.new)
    @employee = employee
    @calculator = calculator
  end
  
  def calculate
    @calculator.calculate(@employee)
  end
end
```

## 📝 Documentación de Código

### Comentarios en Métodos Complejos
```ruby
# Calculate the total worked hours excluding lunch time
# 
# @param check_in [AttendanceRecord] The check-in record
# @param check_out [AttendanceRecord] The check-out record
# @return [Float] Total hours worked
def calculate_worked_hours(check_in, check_out)
  total_time = check_out.timestamp - check_in.timestamp
  lunch_time = calculate_lunch_duration
  
  (total_time - lunch_time) / 3600.0
end
```

### Headers de Archivo
```ruby
# frozen_string_literal: true

# Service for handling complex payroll calculations
# Includes overtime, deductions, and bonuses
#
# Example:
#   service = PayrollService.new(employee)
#   result = service.calculate_monthly(1, 2025)
#
class PayrollService
  # ...
end
```

## 🧪 Testing Guidelines

### Estructura de Tests
```ruby
RSpec.describe EmployeeService do
  describe '#create_employee' do
    context 'with valid params' do
      it 'creates employee successfully' do
        # Test
      end
      
      it 'generates credentials' do
        # Test
      end
    end
    
    context 'with invalid params' do
      it 'returns error' do
        # Test
      end
    end
  end
end
```

## 🚨 Manejo de Errores

### Excepciones Personalizadas
```ruby
# lib/errors/attendance_error.rb
module Errors
  class AttendanceError < StandardError; end
  class DuplicateRecordError < AttendanceError; end
  class OutOfRangeError < AttendanceError; end
end

# Uso
raise Errors::DuplicateRecordError, 'Ya registraste entrada hoy'
```

### Rescue en Services
```ruby
def execute
  # Lógica
  success_result(data)
rescue ActiveRecord::RecordInvalid => e
  error_result(e.record.errors.full_messages)
rescue Errors::AttendanceError => e
  error_result(e.message)
rescue => e
  error_result("Error inesperado: #{e.message}")
end
```

## 📊 Performance

### N+1 Queries
```ruby
# Malo ❌
employees = Employee.all
employees.each do |employee|
  puts employee.company.name  # N+1 query!
end

# Bueno ✅
employees = Employee.includes(:company)
employees.each do |employee|
  puts employee.company.name
end
```

### Usar Scopes
```ruby
# Bueno ✅
scope :active, -> { where(is_active: true) }
scope :by_company, ->(id) { where(company_id: id) }

# Uso
Employee.active.by_company(company_id)
```

## 🔐 Seguridad

### Strong Parameters
```ruby
def employee_params
  params.require(:employee).permit(
    :name,
    :dni,
    :job_position,
    # NO incluir: :is_admin, :role, etc
  )
end
```

### Autorización
```ruby
before_action :authorize_access

def authorize_access
  unless can_modify?(@resource)
    render_forbidden
  end
end
```

## 📚 Recursos

- [Ruby Style Guide](https://rubystyle.guide/)
- [Rails Best Practices](https://github.com/flyerhzm/rails_best_practices)
- [SOLID Principles](https://www.digitalocean.com/community/conceptual_articles/s-o-l-i-d-the-first-five-principles-of-object-oriented-design)
