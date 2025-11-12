# == Schema Information
#
# Table name: payroll_calculations
#
#  id                  :uuid             not null, primary key
#  company_id          :uuid             not null
#  employee_id         :uuid             not null
#  period_start        :date             not null
#  period_end          :date             not null
#  total_hours_worked  :decimal(10, 2)   default(0.0)
#  overtime_hours      :decimal(10, 2)   default(0.0)
#  late_incidents      :integer          default(0)
#  total_earnings      :decimal(10, 2)   default(0.0)
#  total_deductions    :decimal(10, 2)   default(0.0)
#  net_pay             :decimal(10, 2)   default(0.0)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class PayrollCalculation < ApplicationRecord
  # Relationships
  belongs_to :company
  belongs_to :employee
  
  # Validations
  validates :period_start, :period_end, presence: true
  validates :total_hours_worked, :total_earnings, :total_deductions, :net_pay,
            numericality: { greater_than_or_equal_to: 0 }
  validate :end_date_after_start_date
  
  # Scopes
  scope :by_employee, ->(employee_id) { where(employee_id: employee_id) }
  scope :by_company, ->(company_id) { where(company_id: company_id) }
  scope :by_period, ->(start_date, end_date) { 
    where('period_start >= ? AND period_end <= ?', start_date, end_date) 
  }
  scope :recent, -> { order(period_end: :desc) }
  
  # Instance methods
  def calculate_from_attendance_records
    records = employee.attendance_records.by_date_range(period_start, period_end)
    
    hours_data = calculate_hours_worked(records)
    self.total_hours_worked = hours_data[:total_hours]
    self.late_incidents = hours_data[:late_incidents]
    
    # Calculate earnings
    hourly_rate = employee.hourly_salary || 0
    self.total_earnings = total_hours_worked * hourly_rate
    
    # Calculate deductions
    deduction_rate = employee.hourly_deduction || 0
    total_late_minutes = hours_data[:total_late_minutes]
    late_deduction = (total_late_minutes / 60.0) * deduction_rate
    self.total_deductions = late_deduction
    
    # Calculate net pay
    self.net_pay = total_earnings - total_deductions
    
    save!
  end
  
  private
  
  def calculate_hours_worked(records)
    total_minutes = 0
    late_incidents = 0
    total_late_minutes = 0
    
    # Group by date
    records_by_date = records.group_by(&:record_date)
    
    records_by_date.each do |date, day_records|
      entrance = day_records.find { |r| r.attendance_type == 'entrance' }
      exit_record = day_records.find { |r| r.attendance_type == 'exit' }
      lunch_start = day_records.find { |r| r.attendance_type == 'lunch_start' }
      lunch_end = day_records.find { |r| r.attendance_type == 'lunch_end' }
      
      if entrance && exit_record
        minutes = ((exit_record.timestamp - entrance.timestamp) / 60).to_i
        
        # Subtract lunch time
        if lunch_start && lunch_end
          lunch_minutes = ((lunch_end.timestamp - lunch_start.timestamp) / 60).to_i
          minutes -= lunch_minutes
        end
        
        total_minutes += minutes
      end
      
      if entrance&.is_late
        late_incidents += 1
        total_late_minutes += entrance.minutes_late || 0
      end
    end
    
    {
      total_hours: total_minutes / 60.0,
      late_incidents: late_incidents,
      total_late_minutes: total_late_minutes
    }
  end
  
  def end_date_after_start_date
    return unless period_start && period_end
    errors.add(:period_end, 'must be after period start') if period_end < period_start
  end
end
