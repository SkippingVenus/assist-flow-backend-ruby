# Companies Controller
module Api
  module V1
    class CompaniesController < BaseController
      before_action :require_admin, except: [:index]
      before_action :set_company, only: [:show, :update, :destroy]
      
      # GET /api/v1/companies
      def index
        companies = Company.all.order(created_at: :desc)
        render_success(companies)
      end
      
      # GET /api/v1/companies/:id
      def show
        if @company.id != current_user.company_id
          return render_forbidden
        end
        
        render_success({
          **@company.attributes,
          locations: @company.company_locations,
          total_employees: @company.employees.active.count,
          total_locations: @company.company_locations.count
        })
      end
      
      # PUT /api/v1/companies/:id
      def update
        if @company.id != current_user.company_id
          return render_forbidden
        end
        
        if @company.update(company_params)
          render_success({
            message: 'Empresa actualizada exitosamente',
            company: @company
          })
        else
          render json: { errors: @company.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      # POST /api/v1/companies/:id/locations
      def add_location
        company = Company.find(params[:id])
        
        if company.id != current_user.company_id
          return render_forbidden
        end
        
        location = company.company_locations.build(location_params)
        
        if location.save
          render_success({
            message: 'Ubicación agregada exitosamente',
            location: location
          }, :created)
        else
          render json: { errors: location.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      # PUT /api/v1/companies/:id/locations/:location_id
      def update_location
        company = Company.find(params[:id])
        
        if company.id != current_user.company_id
          return render_forbidden
        end
        
        location = company.company_locations.find(params[:location_id])
        
        if location.update(location_params)
          render_success({
            message: 'Ubicación actualizada exitosamente',
            location: location
          })
        else
          render json: { errors: location.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      # DELETE /api/v1/companies/:id/locations/:location_id
      def remove_location
        company = Company.find(params[:id])
        
        if company.id != current_user.company_id
          return render_forbidden
        end
        
        location = company.company_locations.find(params[:location_id])
        location.destroy
        
        render_success({ message: 'Ubicación eliminada exitosamente' })
      end
      
      private
      
      def set_company
        @company = Company.find(params[:id])
      end
      
      def company_params
        params.permit(:name, :work_start_time, :work_end_time, :late_threshold_minutes)
      end
      
      def location_params
        params.permit(:name, :latitude, :longitude, :radius_meters)
      end
    end
  end
end
