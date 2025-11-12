# Sample data for testing
require 'bcrypt'

puts 'Seeding database...'

# Create a company
company = Company.create!(
  name: 'Empresa Demo',
  work_start_time: '08:00',
  work_end_time: '17:00',
  late_threshold_minutes: 15
)
puts "Created company: #{company.name}"

# Create company locations
location1 = company.company_locations.create!(
  name: 'Oficina Principal',
  latitude: -12.046374,
  longitude: -77.042793,
  radius_meters: 100
)

location2 = company.company_locations.create!(
  name: 'Sucursal',
  latitude: -12.053748,
  longitude: -77.034116,
  radius_meters: 150
)
puts "Created #{company.company_locations.count} locations"

# Create admin profile
admin = company.profiles.create!(
  email: 'admin@demo.com',
  password: 'Admin123!',
  full_name: 'Administrador Demo'
)
puts "Created admin: #{admin.email} / Admin123!"

# Create employees
employees_data = [
  { name: 'Juan Pérez', dni: '12345678', phone: '999111222', email: 'juan@demo.com', job_position: 'Desarrollador', salary: 3500 },
  { name: 'María García', dni: '87654321', phone: '999333444', email: 'maria@demo.com', job_position: 'Diseñadora', salary: 3200 },
  { name: 'Carlos López', dni: '11223344', phone: '999555666', email: 'carlos@demo.com', job_position: 'Analista', salary: 3000 },
  { name: 'Ana Torres', dni: '44332211', phone: '999777888', email: 'ana@demo.com', job_position: 'Gerente', salary: 4500 },
  { name: 'Pedro Sánchez', dni: '55667788', phone: '999888999', email: 'pedro@demo.com', job_position: 'Contador', salary: 3800 }
]

employees = []
employees_data.each do |emp_data|
  pin = format('%04d', rand(1000..9999))
  password = "Pass#{rand(1000..9999)}"
  
  employee = company.employees.create!(
    name: emp_data[:name],
    dni: emp_data[:dni],
    phone: emp_data[:phone],
    email: emp_data[:email],
    job_position: emp_data[:job_position],
    salary: emp_data[:salary],
    pin: pin,
    password: password,
    is_active: true
  )
  
  employees << employee
  puts "Created employee: #{employee.name} - PIN: #{pin} / Password: #{password}"
end

# Create attendance records for the last 7 days
7.times do |day|
  date = Date.today - day.days
  next if date.saturday? || date.sunday?
  
  employees.each do |employee|
    # Entrance
    entrance_time = date.to_time + 8.hours + rand(0..30).minutes
    entrance = employee.attendance_records.create!(
      company: company,
      attendance_type: :entrance,
      timestamp: entrance_time,
      record_date: date,
      latitude: location1.latitude,
      longitude: location1.longitude,
      is_late: entrance_time.hour >= 8 && entrance_time.min > 15,
      minutes_late: entrance_time.hour >= 8 && entrance_time.min > 15 ? entrance_time.min - 15 : 0
    )
    
    # Exit
    exit_time = date.to_time + 17.hours + rand(0..60).minutes
    employee.attendance_records.create!(
      company: company,
      attendance_type: :exit,
      timestamp: exit_time,
      record_date: date,
      latitude: location1.latitude,
      longitude: location1.longitude
    )
  end
end
puts "Created attendance records for the last 7 working days"

# Create vacation requests
employees.first(2).each do |employee|
  employee.vacation_requests.create!(
    company: company,
    start_date: Date.today + 30.days,
    end_date: Date.today + 37.days,
    reason: 'Vacaciones programadas',
    status: :pending
  )
end
puts "Created #{VacationRequest.count} vacation requests"

# Create some notifications
employees.each do |employee|
  Notification.create_tardiness_notification(
    employee,
    15,
    Date.today
  )
end
puts "Created #{Notification.count} notifications"

puts "\n=== Seed completed successfully ==="
puts "\nAdmin credentials:"
puts "  Email: admin@demo.com"
puts "  Password: Admin123!"
puts "\nEmployee credentials (check output above for PINs and Passwords)"
