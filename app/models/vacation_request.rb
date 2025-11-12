# == Schema Information
#
# Table name: vacation_requests
#
#  id                :uuid             not null, primary key
#  company_id        :uuid             not null
#  employee_id       :uuid             not null
#  start_date        :date             not null
#  end_date          :date             not null
#  total_days        :integer          not null
#  reason            :text
#  status            :string           default("pending")
#  approved_by       :uuid
#  approved_at       :datetime
#  rejection_reason  :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class VacationRequest < ApplicationRecord
  # Relationships
  belongs_to :company
  belongs_to :employee
  belongs_to :approver, class_name: 'Profile', foreign_key: 'approved_by', optional: true
  
  # Enums
  enum status: {
    pending: 'pending',
    approved: 'approved',
    rejected: 'rejected'
  }
  
  # Validations
  validates :start_date, :end_date, :total_days, presence: true
  validates :status, inclusion: { in: statuses.keys }
  validate :end_date_after_start_date
  
  # Callbacks
  before_validation :calculate_total_days, on: :create
  
  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :approved, -> { where(status: 'approved') }
  scope :rejected, -> { where(status: 'rejected') }
  scope :by_employee, ->(employee_id) { where(employee_id: employee_id) }
  scope :by_company, ->(company_id) { where(company_id: company_id) }
  
  # Instance methods
  def approve!(approved_by_profile)
    update!(
      status: 'approved',
      approved_by: approved_by_profile.id,
      approved_at: Time.current
    )
  end
  
  def reject!(approved_by_profile, reason)
    update!(
      status: 'rejected',
      approved_by: approved_by_profile.id,
      approved_at: Time.current,
      rejection_reason: reason
    )
  end
  
  private
  
  def calculate_total_days
    return unless start_date && end_date
    self.total_days = (end_date - start_date).to_i + 1
  end
  
  def end_date_after_start_date
    return unless start_date && end_date
    errors.add(:end_date, 'must be after start date') if end_date < start_date
  end
end
