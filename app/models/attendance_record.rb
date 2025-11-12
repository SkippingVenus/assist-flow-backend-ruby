# == Schema Information
#
# Table name: attendance_records
#
#  id              :uuid             not null, primary key
#  employee_id     :uuid             not null
#  attendance_type :string           not null
#  timestamp       :datetime         not null
#  record_date     :date             not null
#  is_late         :boolean          default(FALSE)
#  minutes_late    :integer          default(0)
#  latitude        :decimal(10, 8)
#  longitude       :decimal(11, 8)
#  created_at      :datetime         not null
#

class AttendanceRecord < ApplicationRecord
  # Relationships
  belongs_to :employee
  has_one :company, through: :employee
  
  # Enums
  enum attendance_type: {
    entrance: 'entrance',
    exit: 'exit',
    lunch_start: 'lunch_start',
    lunch_end: 'lunch_end'
  }
  
  # Validations
  validates :attendance_type, presence: true, inclusion: { in: attendance_types.keys }
  validates :timestamp, presence: true
  validates :record_date, presence: true
  validates :latitude, numericality: true, allow_nil: true
  validates :longitude, numericality: true, allow_nil: true
  
  # Callbacks
  before_validation :set_defaults, on: :create
  
  # Scopes
  scope :by_employee, ->(employee_id) { where(employee_id: employee_id) }
  scope :by_date, ->(date) { where(record_date: date) }
  scope :by_date_range, ->(start_date, end_date) { where(record_date: start_date..end_date) }
  scope :late_records, -> { where(is_late: true) }
  scope :today, -> { where(record_date: Date.today) }
  scope :this_month, -> { where(record_date: Date.today.beginning_of_month..Date.today.end_of_month) }
  
  # Instance methods
  def check_tardiness
    return unless entrance? && employee.company.expected_start_time
    
    self.is_late = employee.company.is_late?(timestamp)
    self.minutes_late = employee.company.calculate_late_minutes(timestamp) if is_late
  end
  
  private
  
  def set_defaults
    self.timestamp ||= Time.current
    self.record_date ||= Date.today
    check_tardiness
  end
end
