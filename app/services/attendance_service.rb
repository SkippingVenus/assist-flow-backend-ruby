# Service for handling attendance business logic
# Implements MVVM pattern by separating business logic from controllers
class AttendanceService
  attr_reader :employee

  def initialize(employee)
    @employee = employee
  end

  # Record attendance (check-in or check-out)
  def record_attendance(attendance_type:, latitude: nil, longitude: nil)
    return error_result('Tipo de asistencia inválido') unless valid_attendance_type?(attendance_type)
    
    # Validate location if provided
    if latitude && longitude
      location_valid = validate_location(latitude, longitude)
      return error_result('Fuera del rango de ubicación permitido') unless location_valid
    end

    # Check for duplicate records
    if duplicate_record_today?(attendance_type)
      return error_result("Ya registraste #{attendance_type_label(attendance_type)} hoy")
    end

    # Create attendance record
    record = employee.attendance_records.build(
      attendance_type: attendance_type,
      timestamp: Time.current,
      latitude: latitude,
      longitude: longitude
    )

    # Calculate lateness for check-in
    if attendance_type == 'check_in'
      calculate_lateness(record)
    end

    if record.save
      # Send notification if late
      send_late_notification(record) if record.is_late

      success_result(
        message: 'Asistencia registrada exitosamente',
        record: AttendanceRecordSerializer.new(record).as_json
      )
    else
      error_result(record.errors.full_messages)
    end
  end

  # Get today's attendance summary
  def today_summary
    today_records = employee.attendance_records.where(
      'DATE(timestamp) = ?', Date.today
    ).order(timestamp: :asc)

    check_in = today_records.find_by(attendance_type: 'check_in')
    lunch_start = today_records.find_by(attendance_type: 'lunch_start')
    lunch_end = today_records.find_by(attendance_type: 'lunch_end')
    check_out = today_records.find_by(attendance_type: 'check_out')

    {
      date: Date.today,
      check_in: check_in ? AttendanceRecordSerializer.new(check_in).summary : nil,
      lunch_start: lunch_start ? AttendanceRecordSerializer.new(lunch_start).summary : nil,
      lunch_end: lunch_end ? AttendanceRecordSerializer.new(lunch_end).summary : nil,
      check_out: check_out ? AttendanceRecordSerializer.new(check_out).summary : nil,
      total_hours: calculate_total_hours(check_in, check_out)
    }
  end

  # Get monthly statistics
  def monthly_stats(month, year)
    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month

    records = employee.attendance_records
                     .where(attendance_type: 'check_in')
                     .where('DATE(timestamp) BETWEEN ? AND ?', start_date, end_date)

    total_days = records.count
    late_days = records.where(is_late: true).count
    on_time_days = total_days - late_days
    total_late_minutes = records.sum(:minutes_late)

    {
      month: month,
      year: year,
      total_days: total_days,
      late_days: late_days,
      on_time_days: on_time_days,
      total_late_minutes: total_late_minutes,
      average_late_minutes: late_days > 0 ? (total_late_minutes.to_f / late_days).round(2) : 0
    }
  end

  # Class method: Company daily report
  def self.company_daily_report(company, date = Date.today)
    employees = company.employees.active
    
    report_data = employees.map do |emp|
      service = new(emp)
      today_records = emp.attendance_records.where('DATE(timestamp) = ?', date)
      
      {
        employee: EmployeeSerializer.new(emp).summary,
        check_in: today_records.find_by(attendance_type: 'check_in'),
        check_out: today_records.find_by(attendance_type: 'check_out'),
        is_present: today_records.exists?(attendance_type: 'check_in'),
        is_late: today_records.exists?(attendance_type: 'check_in', is_late: true)
      }
    end

    {
      date: date,
      company: CompanySerializer.new(company).summary,
      total_employees: employees.count,
      present: report_data.count { |r| r[:is_present] },
      absent: report_data.count { |r| !r[:is_present] },
      late: report_data.count { |r| r[:is_late] },
      employees: report_data
    }
  end

  private

  def valid_attendance_type?(type)
    %w[check_in lunch_start lunch_end check_out].include?(type)
  end

  def attendance_type_label(type)
    {
      'check_in' => 'entrada',
      'lunch_start' => 'inicio de almuerzo',
      'lunch_end' => 'fin de almuerzo',
      'check_out' => 'salida'
    }[type]
  end

  def duplicate_record_today?(attendance_type)
    employee.attendance_records.exists?(
      attendance_type: attendance_type,
      timestamp: Date.today.beginning_of_day..Date.today.end_of_day
    )
  end

  def validate_location(latitude, longitude)
    # Get active company locations
    locations = employee.company.company_locations.where(is_active: true)
    return true if locations.empty? # No validation if no locations set

    locations.any? do |location|
      distance = Geocoder::Calculations.distance_between(
        [latitude, longitude],
        [location.latitude, location.longitude],
        units: :km
      )
      distance * 1000 <= location.radius_meters # Convert to meters
    end
  end

  def calculate_lateness(record)
    company = employee.company
    
    if company.is_late?(record.timestamp)
      record.is_late = true
      record.minutes_late = company.calculate_late_minutes(record.timestamp)
      employee.increment_late_count!
    else
      record.is_late = false
      record.minutes_late = 0
    end
  end

  def calculate_total_hours(check_in, check_out)
    return 0 unless check_in && check_out
    
    hours = (check_out.timestamp - check_in.timestamp) / 3600.0
    hours.round(2)
  end

  def send_late_notification(record)
    NotificationService.create_notification(
      user: employee,
      title: 'Llegada tardía registrada',
      message: "Llegaste #{record.minutes_late} minutos tarde el #{record.timestamp.strftime('%d/%m/%Y')}",
      notification_type: 'late_arrival'
    )
  end

  def success_result(data)
    { success: true }.merge(data)
  end

  def error_result(message)
    { success: false, error: message }
  end
end
