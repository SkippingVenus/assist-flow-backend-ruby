# == Schema Information
#
# Table name: notifications
#
#  id          :uuid             not null, primary key
#  company_id  :uuid             not null
#  employee_id :uuid             not null
#  type        :string           not null
#  title       :string           not null
#  message     :text             not null
#  is_read     :boolean          default(FALSE)
#  metadata    :jsonb
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Notification < ApplicationRecord
  # Relationships
  belongs_to :company
  belongs_to :employee
  
  # Validations
  validates :title, :message, presence: true
  validates :type, inclusion: { in: %w[tardiness lunch_excess vacation_approved vacation_rejected general] }
  
  # Scopes
  scope :unread, -> { where(is_read: false) }
  scope :read, -> { where(is_read: true) }
  scope :by_employee, ->(employee_id) { where(employee_id: employee_id) }
  scope :by_type, ->(type) { where(type: type) }
  scope :recent, -> { order(created_at: :desc) }
  
  # Instance methods
  def mark_as_read!
    update!(is_read: true)
  end
  
  # Class methods
  def self.create_tardiness_notification(employee, minutes_late)
    create!(
      company_id: employee.company_id,
      employee_id: employee.id,
      type: 'tardiness',
      title: 'Llegada tarde',
      message: "Llegaste #{minutes_late} minutos tarde",
      metadata: { minutes_late: minutes_late, date: Date.today }
    )
  end
  
  def self.create_vacation_approved_notification(vacation_request)
    create!(
      company_id: vacation_request.company_id,
      employee_id: vacation_request.employee_id,
      type: 'vacation_approved',
      title: 'Vacaciones aprobadas',
      message: "Tu solicitud de vacaciones del #{vacation_request.start_date} al #{vacation_request.end_date} fue aprobada",
      metadata: { vacation_request_id: vacation_request.id }
    )
  end
  
  def self.create_vacation_rejected_notification(vacation_request)
    create!(
      company_id: vacation_request.company_id,
      employee_id: vacation_request.employee_id,
      type: 'vacation_rejected',
      title: 'Vacaciones rechazadas',
      message: "Tu solicitud de vacaciones fue rechazada. Motivo: #{vacation_request.rejection_reason || 'No especificado'}",
      metadata: { vacation_request_id: vacation_request.id }
    )
  end
end
