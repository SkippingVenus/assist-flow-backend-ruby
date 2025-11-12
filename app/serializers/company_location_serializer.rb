# Serializer for CompanyLocation model
class CompanyLocationSerializer
  attr_reader :location

  def initialize(location)
    @location = location
  end

  def as_json(options = {})
    {
      id: location.id,
      name: location.name,
      address: location.address,
      latitude: location.latitude.to_f,
      longitude: location.longitude.to_f,
      radius_meters: location.radius_meters,
      is_active: location.is_active,
      created_at: location.created_at,
      updated_at: location.updated_at
    }
  end

  def summary
    {
      id: location.id,
      name: location.name,
      address: location.address
    }
  end
end
