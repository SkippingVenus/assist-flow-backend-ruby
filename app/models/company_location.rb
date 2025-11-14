# == Schema Information
#
# Table name: company_locations
#
#  id             :uuid             not null, primary key
#  company_id     :uuid             not null
#  name           :string           not null
#  latitude       :decimal(10, 8)   not null
#  longitude      :decimal(11, 8)   not null
#  radius_meters  :integer          default(100)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class CompanyLocation < ApplicationRecord
  # Relationships
  belongs_to :company
  
  # Validations
  validates :name, presence: true
  validates :latitude, presence: true, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude, presence: true, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
  validates :radius_meters, numericality: { greater_than: 0 }, allow_nil: true
  
  # Instance methods
  def within_range?(lat, lng)
    distance = calculate_distance(lat, lng)
    distance <= radius_meters
  end
  
  def calculate_distance(lat, lng)
    # Haversine formula
    earth_radius = 6_371_000 # meters
    
    lat1_rad = to_radians(latitude.to_f)
    lat2_rad = to_radians(lat.to_f)
    delta_lat = to_radians(lat.to_f - latitude.to_f)
    delta_lng = to_radians(lng.to_f - longitude.to_f)
    
    a = Math.sin(delta_lat / 2)**2 +
        Math.cos(lat1_rad) * Math.cos(lat2_rad) *
        Math.sin(delta_lng / 2)**2
    
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    
    earth_radius * c
  end
  
  private
  
  def to_radians(degrees)
    degrees * Math::PI / 180
  end
end
