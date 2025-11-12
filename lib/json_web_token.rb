# JSON Web Token utility class
class JsonWebToken
  SECRET_KEY = ENV.fetch('JWT_SECRET_KEY') { Rails.application.credentials.secret_key_base }
  EXPIRATION_HOURS = ENV.fetch('JWT_EXPIRATION_HOURS', 24).to_i
  
  def self.encode(payload, exp = EXPIRATION_HOURS.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY, 'HS256')
  end
  
  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' })[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError => e
    nil
  end
end
