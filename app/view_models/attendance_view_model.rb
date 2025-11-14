# ViewModel for Attendance presentation logic
# Handles attendance data transformation and statistics

class AttendanceViewModel
  attr_reader :employee, :company
  
  def initialize(employee)
    @employee = employee
    @company = employee.company
  end
  
  # Record attendance with geolocation validation
  def self.record_attendance(employee, params)
    # Validate geolocation if provided
    if params[:latitude].present? && params[:longitude].present?
      location_validation = validate_location(
        employee.company,
        params[:latitude],
        params[:longitude]
      )
      
      unless location_validation[:valid]
        return {
          success: false,
          error: location_validation[:message]
        }
      end
    end
    
    # Create attendance record
    record = employee.attendance_records.new(
      company_id: employee.company_id,
      attendance_type: params[:attendance_type],
      latitude: params[:latitude],
      longitude: params[:longitude]
    )
    
    # Check for tardiness on entrance
    if record.entrance? && record.is_late
      employee.increment_late_count!
      
      # Create tardiness notification
      Notification.create_tardiness_notification(
        employee,
        record.minutes_late
      )
    end
    
    if record.save
      {
        success: true,
        record: record
      }
    else
      {
        success: false,
        errors: record.errors.full_messages
      }
    end
  end
  
  # Validate if employee is within company location
  def self.validate_location(company, latitude, longitude)
    locations = company.company_locations
    
    if locations.empty?
      return { valid: true, message: 'No location restrictions' }
    end
    
    within_range = locations.any? do |location|
      location.within_range?(latitude, longitude)
    end
    
    if within_range
      { valid: true, message: 'Within range' }
    else
      { valid: false, message: 'Fuera del rango permitido' }
    end
  end
  
  # Get today's attendance summary
  def today_summary
    records = employee.attendance_records.today
    
    {
      date: Date.today,
      employee_id: employee.id,
      employee_name: employee.name,
      records: records.map { |r| record_summary(r) },
      has_entrance: records.any?(&:entrance?),
      has_exit: records.any?(&:exit?)
    }
  end
  
  # Get monthly statistics
  def monthly_stats(month = Date.today.month, year = Date.today.year)
    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month
    
    records = employee.attendance_records.by_date_range(start_date, end_date)
    
    unique_days = records.pluck(:record_date).uniq
    late_records = records.late_records
    
    {
      period: { month: month, year: year },
      total_days_worked: unique_days.count,
      total_late_days: late_records.pluck(:record_date).uniq.count,
      total_late_minutes: late_records.sum(:minutes_late),
      average_late_minutes: late_records.any? ? (late_records.sum(:minutes_late) / late_records.count) : 0,
      late_count: employee.late_count
    }
  end
  
  # Company daily report
  def self.company_daily_report(company, date = Date.today)
    employees = company.employees.active.includes(:attendance_records)
    
    summary = employees.map do |emp|
      records = emp.attendance_records.by_date(date)
      
      entrance = records.find(&:entrance?)
      exit_record = records.find(&:exit?)
      
      {
        employee_id: emp.id,
        employee_name: emp.name,
        dni: emp.dni,
        job_position: emp.job_position,
        entrance_time: entrance&.timestamp,
        exit_time: exit_record&.timestamp,
        is_late: entrance&.is_late || false,
        minutes_late: entrance&.minutes_late || 0,
        status: entrance ? (exit_record ? 'completed' : 'in_progress') : 'absent'
      }
    end
    
    {
      date: date,
      total_employees: employees.count,
      present: summary.count { |s| s[:status] != 'absent' },
      absent: summary.count { |s| s[:status] == 'absent' },
      late: summary.count { |s| s[:is_late] },
      employees: summary
    }
  end
  
  private
  
  # Instance method for record summary
  def record_summary(record)
    {
      id: record.id,
      attendance_type: record.attendance_type,
      timestamp: record.timestamp,
      is_late: record.is_late,
      minutes_late: record.minutes_late
    }
  end
  
  # Class method for record summary
  def self.record_summary(record)
    {
      id: record.id,
      attendance_type: record.attendance_type,
      timestamp: record.timestamp,
      is_late: record.is_late,
      minutes_late: record.minutes_late
    }
  end
end
