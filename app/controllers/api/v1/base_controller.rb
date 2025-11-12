# Base controller for API v1
module Api
  module V1
    class BaseController < ApplicationController
      before_action :authenticate_request
      
      attr_reader :current_user, :current_user_type
      
      private
      
      def authenticate_request
        header = request.headers['Authorization']
        return render_unauthorized unless header
        
        token = header.split(' ').last
        decoded = JsonWebToken.decode(token)
        
        return render_unauthorized unless decoded
        
        @current_user_type = decoded[:type]
        
        if decoded[:type] == 'admin'
          @current_user = Profile.find_by(id: decoded[:id])
        elsif decoded[:type] == 'employee'
          @current_user = Employee.find_by(id: decoded[:id], is_active: true)
        end
        
        render_unauthorized unless @current_user
      rescue ActiveRecord::RecordNotFound
        render_unauthorized
      end
      
      def require_admin
        render_forbidden unless current_user_type == 'admin'
      end
      
      def require_employee
        render_forbidden unless current_user_type == 'employee'
      end
      
      def render_unauthorized(message = 'No autorizado')
        render json: { error: message }, status: :unauthorized
      end
      
      def render_forbidden(message = 'Acceso denegado')
        render json: { error: message }, status: :forbidden
      end
      
      def render_not_found(message = 'Recurso no encontrado')
        render json: { error: message }, status: :not_found
      end
      
      def render_bad_request(errors)
        render json: { errors: errors }, status: :bad_request
      end
      
      def render_success(data, status = :ok)
        render json: data, status: status
      end
    end
  end
end
