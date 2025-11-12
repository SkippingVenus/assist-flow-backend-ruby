# Service for employee management business logic
class EmployeeService
  attr_reader :employee

  def initialize(employee = nil)
    @employee = employee
  end

  # Create employee with auto-generated credentials
  def self.create_employee(params, created_by_profile)
    # Generate credentials
    pin = Employee.generate_pin
    password = Employee.generate_password

    # Build employee
    employee = Employee.new(params)
    employee.company_id = created_by_profile.company_id
    employee.created_by = created_by_profile.id
    employee.pin = pin
    employee.password = password

    if employee.save
      # Send notification to admin
      NotificationService.create_notification(
        user: created_by_profile,
        title: 'Empleado creado',
        message: "El empleado #{employee.name} ha sido creado exitosamente",
        notification_type: 'employee_created'
      )

      {
        success: true,
        employee: employee,
        credentials: {
          pin: pin,
          password: password
        }
      }
    else
      {
        success: false,
        errors: employee.errors.full_messages
      }
    end
  end

  # Update employee
  def update_employee(params)
    if employee.update(params)
      {
        success: true,
        employee: employee
      }
    else
      {
        success: false,
        errors: employee.errors.full_messages
      }
    end
  end

  # Reset credentials
  def reset_credentials(reset_pin: false, reset_password: false)
    new_credentials = {}

    if reset_pin
      new_pin = Employee.generate_pin
      employee.pin = new_pin
      new_credentials[:pin] = new_pin
    end

    if reset_password
      new_password = Employee.generate_password
      employee.password = new_password
      new_credentials[:password] = new_password
    end

    if employee.save
      {
        success: true,
        credentials: new_credentials
      }
    else
      {
        success: false,
        errors: employee.errors.full_messages
      }
    end
  end

  # Deactivate employee
  def deactivate
    if employee.update(is_active: false)
      {
        success: true,
        message: 'Empleado desactivado exitosamente'
      }
    else
      {
        success: false,
        errors: employee.errors.full_messages
      }
    end
  end

  # Activate employee
  def activate
    if employee.update(is_active: true)
      {
        success: true,
        message: 'Empleado activado exitosamente'
      }
    else
      {
        success: false,
        errors: employee.errors.full_messages
      }
    end
  end

  # Get employee statistics
  def statistics(month = Date.today.month, year = Date.today.year)
    attendance_service = AttendanceService.new(employee)
    monthly_stats = attendance_service.monthly_stats(month, year)

    {
      employee: EmployeeSerializer.new(employee).summary,
      period: { month: month, year: year },
      attendance: monthly_stats,
      salary_info: {
        hourly_salary: employee.hourly_salary.to_f,
        hourly_deduction: employee.hourly_deduction.to_f,
        late_count: employee.late_count
      }
    }
  end
end
