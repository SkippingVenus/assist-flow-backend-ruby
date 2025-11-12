# == Schema Information
#
# Table name: profiles
#
#  id              :uuid             not null, primary key
#  name            :string
#  email           :string           not null
#  password_digest :string           not null
#  user_role       :string           default("admin")
#  company_id      :uuid
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Profile < ApplicationRecord
  # Relationships
  belongs_to :company, optional: true
  
  # Secure password
  has_secure_password
  
  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || password.present? }
  validates :user_role, inclusion: { in: %w[admin super_admin] }
  
  # Scopes
  scope :admins, -> { where(user_role: 'admin') }
  scope :super_admins, -> { where(user_role: 'super_admin') }
  
  # Instance methods
  def admin?
    user_role == 'admin'
  end
  
  def super_admin?
    user_role == 'super_admin'
  end
end
