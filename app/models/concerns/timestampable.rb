# Concern for handling timestamp formatting
module Timestampable
  extend ActiveSupport::Concern

  def formatted_created_at
    created_at.strftime('%d/%m/%Y %H:%M')
  end

  def formatted_updated_at
    updated_at.strftime('%d/%m/%Y %H:%M')
  end

  def time_ago
    time_diff = Time.current - created_at

    case time_diff
    when 0..60
      'hace un momento'
    when 61..3600
      "hace #{(time_diff / 60).to_i} minutos"
    when 3601..86_400
      "hace #{(time_diff / 3600).to_i} horas"
    else
      "hace #{(time_diff / 86_400).to_i} días"
    end
  end
end
