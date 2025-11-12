# Service for handling authentication logic
# Separates authentication business logic from controllers (MVVM Pattern)
class AuthenticationService
  class << self
    # Admin registration
    def register_admin(email:, password:, full_name:)
      return error_result('Email ya está registrado') if Profile.exists?(email: email)

      profile = Profile.new(
        email: email,
        password: password,
        full_name: full_name,
        role: 'admin'
      )

      if profile.save
        token = generate_token(profile, 'admin')
        success_result(
          message: 'Registro exitoso',
          token: token,
          user: {
            id: profile.id,
            email: profile.email,
            full_name: profile.full_name,
            role: profile.role
          }
        )
      else
        error_result(profile.errors.full_messages)
      end
    end

    # Admin login
    def admin_login(email:, password:)
      profile = Profile.find_by(email: email, role: 'admin')
      
      unless profile&.authenticate(password)
        return error_result('Credenciales inválidas')
      end

      token = generate_token(profile, 'admin')
      success_result(
        message: 'Login exitoso',
        token: token,
        user: {
          id: profile.id,
          email: profile.email,
          full_name: profile.full_name,
          role: profile.role,
          company_id: profile.company_id
        }
      )
    end

    # Employee login
    def employee_login(company_id:, dni:, pin:)
      employee = Employee.find_by(company_id: company_id, dni: dni, is_active: true)
      
      unless employee&.verify_pin(pin)
        return error_result('Credenciales inválidas')
      end

      token = generate_token(employee, 'employee')
      success_result(
        message: 'Login exitoso',
        token: token,
        user: EmployeeSerializer.new(employee).auth_response
      )
    end

    # Verify token and get user
    def verify_token(token)
      decoded = JsonWebToken.decode(token)
      return error_result('Token inválido') unless decoded

      if decoded[:type] == 'admin'
        user = Profile.find_by(id: decoded[:id])
      elsif decoded[:type] == 'employee'
        user = Employee.find_by(id: decoded[:id], is_active: true)
      end

      return error_result('Usuario no encontrado') unless user

      success_result(
        user: user,
        user_type: decoded[:type]
      )
    rescue StandardError => e
      error_result("Error al verificar token: #{e.message}")
    end

    private

    def generate_token(user, type)
      JsonWebToken.encode(id: user.id, type: type)
    end

    def success_result(data)
      { success: true }.merge(data)
    end

    def error_result(message)
      { success: false, error: message }
    end
  end
end
