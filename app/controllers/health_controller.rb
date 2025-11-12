# Health Check Controller
class HealthController < ActionController::API
  def index
    render json: {
      status: 'ok',
      timestamp: Time.current,
      application: 'AsistControl API',
      version: '1.0.0',
      database: database_status
    }
  end

  private

  def database_status
    ActiveRecord::Base.connection.execute('SELECT 1')
    'connected'
  rescue StandardError => e
    { error: e.message }
  end
end
