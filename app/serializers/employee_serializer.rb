# Serializer for Employee model
# Handles JSON representation for API responses following MVVM pattern
class EmployeeSerializer
  attr_reader :employee

  def initialize(employee)
    @employee = employee
  end

  # Basic employee information
  def as_json(options = {})
    {
      id: employee.id,
      name: employee.name,
      dni: employee.dni,
      job_position: employee.job_position,
      hourly_salary: format_currency(employee.hourly_salary),
      hourly_deduction: format_currency(employee.hourly_deduction),
      late_count: employee.late_count,
      is_active: employee.is_active,
      company_id: employee.company_id,
      created_at: employee.created_at,
      updated_at: employee.updated_at
    }
  end

  # Detailed view with company information
  def detailed
    as_json.merge(
      company: {
        id: employee.company.id,
        name: employee.company.name
      }
    )
  end

  # Summary for lists
  def summary
    {
      id: employee.id,
      name: employee.name,
      dni: employee.dni,
      job_position: employee.job_position,
      is_active: employee.is_active
    }
  end

  # For authentication responses
  def auth_response
    {
      id: employee.id,
      name: employee.name,
      dni: employee.dni,
      job_position: employee.job_position,
      company_id: employee.company_id
    }
  end

  private

  def format_currency(amount)
    return 0.0 unless amount
    amount.to_f.round(2)
  end
end
