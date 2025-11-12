# Payroll Calculations Controller using PayrollViewModel
module Api
  module V1
    class PayrollCalculationsController < BaseController
      before_action :require_admin, except: [:show, :index]
      
      # POST /api/v1/payroll_calculations/calculate
      def calculate
        company = current_user.company
        
        unless params[:period_start] && params[:period_end]
          return render_bad_request(['Period start and end are required'])
        end
        
        result = PayrollViewModel.calculate_payroll(
          company,
          params[:period_start],
          params[:period_end],
          params[:employee_id]
        )
        
        render_success({
          message: 'Nómina calculada exitosamente',
          **result
        })
      end
      
      # GET /api/v1/payroll_calculations
      def index
        if current_user_type == 'admin'
          calculations = current_user.company.payroll_calculations
        else
          calculations = current_user.payroll_calculations
        end
        
        calculations = calculations.includes(:employee)
        
        if params[:employee_id]
          calculations = calculations.where(employee_id: params[:employee_id])
        end
        
        if params[:period_start] && params[:period_end]
          calculations = calculations.by_period(params[:period_start], params[:period_end])
        end
        
        calculations = calculations.recent
        
        view_models = calculations.map { |calc| PayrollViewModel.new(calc).summary }
        render_success(view_models)
      end
      
      # GET /api/v1/payroll_calculations/:id
      def show
        calculation = PayrollCalculation.find(params[:id])
        
        # Check permissions
        if current_user_type == 'admin' && calculation.company_id != current_user.company_id
          return render_forbidden
        end
        
        if current_user_type == 'employee' && calculation.employee_id != current_user.id
          return render_forbidden
        end
        
        view_model = PayrollViewModel.new(calculation)
        render_success(view_model.detailed)
      end
    end
  end
end
