# Attendance Records Controller using AttendanceViewModel
module Api
  module V1
    class AttendanceRecordsController < BaseController
      before_action :require_employee, only: [:create, :today]
      
      # POST /api/v1/attendance_records
      def create
        result = AttendanceViewModel.record_attendance(current_user, attendance_params)
        
        if result[:success]
          record = result[:record]
          render_success({
            message: 'Asistencia registrada exitosamente',
            record: {
              id: record.id,
              attendance_type: record.attendance_type,
              timestamp: record.timestamp,
              is_late: record.is_late,
              minutes_late: record.minutes_late
            }
          }, :created)
        else
          render json: { error: result[:error] || result[:errors] }, status: :unprocessable_entity
        end
      end
      
      # GET /api/v1/attendance_records/today
      def today
        view_model = AttendanceViewModel.new(current_user)
        render_success(view_model.today_summary)
      end
      
      # GET /api/v1/attendance_records/employee/:employee_id
      def by_employee
        employee = Employee.find(params[:employee_id])
        
        # Check permissions
        if current_user_type == 'admin' && employee.company_id != current_user.company_id
          return render_forbidden
        end
        
        if current_user_type == 'employee' && employee.id != current_user.id
          return render_forbidden
        end
        
        records = employee.attendance_records
        
        if params[:start_date] && params[:end_date]
          records = records.by_date_range(params[:start_date], params[:end_date])
        end
        
        records = records.order(timestamp: :desc).limit(params[:limit] || 100)
        
        render_success(records)
      end
      
      # GET /api/v1/attendance_records/company/:company_id/daily
      def company_daily
        return render_forbidden unless current_user_type == 'admin'
        
        company = Company.find(params[:company_id])
        
        if company.id != current_user.company_id
          return render_forbidden
        end
        
        date = params[:date] ? Date.parse(params[:date]) : Date.today
        result = AttendanceViewModel.company_daily_report(company, date)
        
        render_success(result)
      end
      
      # GET /api/v1/attendance_records/stats/:employee_id
      def stats
        employee = Employee.find(params[:employee_id])
        
        # Check permissions
        if current_user_type == 'admin' && employee.company_id != current_user.company_id
          return render_forbidden
        end
        
        if current_user_type == 'employee' && employee.id != current_user.id
          return render_forbidden
        end
        
        view_model = AttendanceViewModel.new(employee)
        month = params[:month]&.to_i || Date.today.month
        year = params[:year]&.to_i || Date.today.year
        
        render_success(view_model.monthly_stats(month, year))
      end
      
      private
      
      def attendance_params
        params.permit(:attendance_type, :latitude, :longitude)
      end
    end
  end
end
