# ViewModel for Payroll presentation logic
# Handles payroll calculations and report generation

class PayrollViewModel
  attr_reader :calculation
  
  def initialize(calculation)
    @calculation = calculation
  end
  
  # Calculate payroll for employees
  def self.calculate_payroll(company, period_start, period_end, employee_id = nil)
    employees = if employee_id
                  Employee.where(id: employee_id, company_id: company.id)
                else
                  company.employees.active
                end
    
    results = []
    
    employees.each do |employee|
      calculation = PayrollCalculation.find_or_initialize_by(
        company_id: company.id,
        employee_id: employee.id,
        period_start: period_start,
        period_end: period_end
      )
      
      calculation.calculate_from_attendance_records
      
      results << {
        employee_id: employee.id,
        employee_name: employee.name,
        total_hours_worked: calculation.total_hours_worked,
        late_incidents: calculation.late_incidents,
        total_earnings: calculation.total_earnings,
        total_deductions: calculation.total_deductions,
        net_pay: calculation.net_pay
      }
    end
    
    {
      period: { start: period_start, end: period_end },
      calculations: results
    }
  end
  
  # Detailed calculation view
  def detailed
    {
      id: calculation.id,
      employee: {
        id: calculation.employee.id,
        name: calculation.employee.name,
        dni: calculation.employee.dni,
        job_position: calculation.employee.job_position,
        hourly_salary: calculation.employee.hourly_salary,
        hourly_deduction: calculation.employee.hourly_deduction
      },
      period: {
        start: calculation.period_start,
        end: calculation.period_end
      },
      hours: {
        total_worked: calculation.total_hours_worked,
        overtime: calculation.overtime_hours
      },
      late: {
        incidents: calculation.late_incidents
      },
      money: {
        total_earnings: calculation.total_earnings,
        total_deductions: calculation.total_deductions,
        net_pay: calculation.net_pay
      },
      created_at: calculation.created_at
    }
  end
  
  # Summary for listing
  def summary
    {
      id: calculation.id,
      employee_id: calculation.employee_id,
      employee_name: calculation.employee.name,
      period_start: calculation.period_start,
      period_end: calculation.period_end,
      total_hours_worked: calculation.total_hours_worked,
      net_pay: calculation.net_pay
    }
  end
  
  # Generate Excel report data
  def self.excel_report_data(company, period_start, period_end)
    calculations = company.payroll_calculations
                          .includes(:employee)
                          .where(period_start: period_start, period_end: period_end)
    
    calculations.map do |calc|
      {
        employee_name: calc.employee.name,
        dni: calc.employee.dni,
        job_position: calc.employee.job_position,
        hours_worked: calc.total_hours_worked.to_f,
        late_incidents: calc.late_incidents,
        total_earnings: calc.total_earnings.to_f,
        total_deductions: calc.total_deductions.to_f,
        net_pay: calc.net_pay.to_f
      }
    end
  end
end
