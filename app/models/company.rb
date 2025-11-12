# == Schema Information
#
# Table name: companies
#
#  id                   :uuid             not null, primary key
#  name                 :string           not null
#  expected_start_time  :time
#  expected_end_time    :time
#  lunch_start_time     :time
#  lunch_end_time       :time
#  created_by           :uuid
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class Company < ApplicationRecord
  # Relationships
  has_many :employees, dependent: :destroy
  has_many :company_locations, dependent: :destroy
  has_many :vacation_requests, dependent: :destroy
  has_many :profiles, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :payroll_calculations, dependent: :destroy
  
  # Validations
  validates :name, presence: true, uniqueness: true
  
  # Scopes
  scope :active, -> { where(active: true) }
  
  # Instance methods
  def within_work_hours?(time = Time.current)
    return true unless expected_start_time && expected_end_time
    
    current_time = time.strftime('%H:%M:%S')
    current_time >= expected_start_time.strftime('%H:%M:%S') && 
    current_time <= expected_end_time.strftime('%H:%M:%S')
  end
  
  def is_late?(time)
    return false unless expected_start_time
    
    time.strftime('%H:%M:%S') > expected_start_time.strftime('%H:%M:%S')
  end
  
  def calculate_late_minutes(time)
    return 0 unless expected_start_time && is_late?(time)
    
    expected = Time.parse(expected_start_time.strftime('%H:%M:%S'))
    actual = Time.parse(time.strftime('%H:%M:%S'))
    ((actual - expected) / 60).to_i
  end
end
