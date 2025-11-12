# Custom validator for location coordinates
class LocationValidator < ActiveModel::Validator
  def validate(record)
    validate_latitude(record)
    validate_longitude(record)
    validate_radius(record)
  end

  private

  def validate_latitude(record)
    return unless record.latitude

    unless record.latitude.between?(-90, 90)
      record.errors.add(:latitude, 'debe estar entre -90 y 90')
    end
  end

  def validate_longitude(record)
    return unless record.longitude

    unless record.longitude.between?(-180, 180)
      record.errors.add(:longitude, 'debe estar entre -180 y 180')
    end
  end

  def validate_radius(record)
    return unless record.radius_meters

    if record.radius_meters <= 0
      record.errors.add(:radius_meters, 'debe ser mayor que 0')
    end

    if record.radius_meters > 10_000
      record.errors.add(:radius_meters, 'no puede ser mayor a 10km')
    end
  end
end
