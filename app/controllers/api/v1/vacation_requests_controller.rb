# Vacation Requests Controller
module Api
  module V1
    class VacationRequestsController < BaseController
      before_action :set_vacation_request, only: [:show, :approve, :reject]
      
      # GET /api/v1/vacation_requests
      def index
        if current_user_type == 'admin'
          requests = current_user.company.vacation_requests
        else
          requests = current_user.vacation_requests
        end
        
        requests = requests.includes(:employee)
        
        if params[:status]
          requests = requests.with_status(params[:status])
        end
        
        if params[:employee_id]
          requests = requests.where(employee_id: params[:employee_id])
        end
        
        requests = requests.order(created_at: :desc)
        
        render_success(requests)
      end
      
      # GET /api/v1/vacation_requests/:id
      def show
        # Check permissions
        if current_user_type == 'admin' && @vacation_request.company_id != current_user.company_id
          return render_forbidden
        end
        
        if current_user_type == 'employee' && @vacation_request.employee_id != current_user.id
          return render_forbidden
        end
        
        render_success(@vacation_request)
      end
      
      # POST /api/v1/vacation_requests
      def create
        employee = if current_user_type == 'employee'
          current_user
        else
          Employee.find(params[:employee_id])
        end
        
        if current_user_type == 'admin' && employee.company_id != current_user.company_id
          return render_forbidden
        end
        
        vacation_request = employee.vacation_requests.build(vacation_request_params)
        
        if vacation_request.save
          render_success({
            message: 'Solicitud de vacaciones creada exitosamente',
            vacation_request: vacation_request
          }, :created)
        else
          render json: { errors: vacation_request.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      # POST /api/v1/vacation_requests/:id/approve
      def approve
        return render_forbidden unless current_user_type == 'admin'
        
        if @vacation_request.company_id != current_user.company_id
          return render_forbidden
        end
        
        @vacation_request.approve!
        
        render_success({
          message: 'Solicitud de vacaciones aprobada',
          vacation_request: @vacation_request
        })
      end
      
      # POST /api/v1/vacation_requests/:id/reject
      def reject
        return render_forbidden unless current_user_type == 'admin'
        
        if @vacation_request.company_id != current_user.company_id
          return render_forbidden
        end
        
        @vacation_request.reject!
        
        render_success({
          message: 'Solicitud de vacaciones rechazada',
          vacation_request: @vacation_request
        })
      end
      
      private
      
      def set_vacation_request
        @vacation_request = VacationRequest.find(params[:id])
      end
      
      def vacation_request_params
        params.permit(:start_date, :end_date, :reason)
      end
    end
  end
end
