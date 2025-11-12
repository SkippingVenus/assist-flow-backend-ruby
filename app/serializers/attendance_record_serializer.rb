# Serializer for AttendanceRecord model
class AttendanceRecordSerializer
  attr_reader :record

  def initialize(record)
    @record = record
  end

  def as_json(options = {})
    {
      id: record.id,
      employee_id: record.employee_id,
      employee_name: record.employee.name,
      attendance_type: record.attendance_type,
      timestamp: record.timestamp,
      latitude: record.latitude&.to_f,
      longitude: record.longitude&.to_f,
      is_late: record.is_late,
      minutes_late: record.minutes_late,
      notes: record.notes,
      created_at: record.created_at
    }
  end

  def summary
    {
      id: record.id,
      attendance_type: record.attendance_type,
      timestamp: record.timestamp,
      is_late: record.is_late,
      minutes_late: record.minutes_late
    }
  end

  def for_report
    {
      employee_name: record.employee.name,
      employee_dni: record.employee.dni,
      attendance_type: record.attendance_type,
      timestamp: record.timestamp.strftime('%Y-%m-%d %H:%M:%S'),
      is_late: record.is_late ? 'Sí' : 'No',
      minutes_late: record.minutes_late
    }
  end
end
