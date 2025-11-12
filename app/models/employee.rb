# == Schema Information
#
# Table name: employees
#
#  id                :uuid             not null, primary key
#  company_id        :uuid             not null
#  name              :string           not null
#  dni               :string           not null
#  job_position      :string           not null
#  pin_hash          :string           not null
#  password_hash     :string
#  hourly_salary     :decimal(10, 2)   default(0.0)
#  hourly_deduction  :decimal(10, 2)   default(0.0)
#  late_count        :integer          default(0)
#  is_active         :boolean          default(TRUE)
#  created_by        :uuid
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Employee < ApplicationRecord
  # Relationships
  belongs_to :company
  has_many :attendance_records, dependent: :destroy
  has_many :vacation_requests, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :payroll_calculations, dependent: :destroy
  
  # Secure password
  has_secure_password validations: false
  
  # Validations
  validates :name, presence: true
  validates :dni, presence: true, uniqueness: true
  validates :job_position, presence: true
  validates :pin_hash, presence: true
  validates :hourly_salary, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :hourly_deduction, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  
  # Callbacks
  before_validation :hash_pin, if: -> { @pin.present? }
  
  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :by_company, ->(company_id) { where(company_id: company_id) }
  scope :search, ->(query) { where("name ILIKE ? OR dni ILIKE ?", "%#{query}%", "%#{query}%") }
  
  # Virtual attributes
  attr_accessor :pin, :plain_password
  
  # Instance methods
  def verify_pin(pin)
    BCrypt::Password.new(pin_hash) == pin
  end
  
  def increment_late_count!
    increment!(:late_count)
  end
  
  # Class methods
  def self.generate_pin
    rand(1000..9999).to_s
  end
  
  def self.generate_password
    SecureRandom.alphanumeric(8)
  end
  
  def self.hash_pin(pin)
    BCrypt::Password.create(pin)
  end
  
  private
  
  def hash_pin
    self.pin_hash = self.class.hash_pin(@pin)
  end
end
