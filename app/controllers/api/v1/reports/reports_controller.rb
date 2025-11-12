# Reports Controller using ViewModels
module Api
  module V1
    module Reports
      class ReportsController < Api::V1::BaseController
        before_action :require_admin
        
        # GET /api/v1/reports/attendance
        def attendance
          unless params[:start_date] && params[:end_date]
            return render_bad_request(['Start date and end date are required'])
          end
          
          company = current_user.company
          records = AttendanceRecord.joins(:employee)
                                   .where(employees: { company_id: company.id })
                                   .by_date_range(params[:start_date], params[:end_date])
          
          if params[:employee_id]
            records = records.where(employee_id: params[:employee_id])
          end
          
          records = records.includes(:employee).order(record_date: :desc, timestamp: :asc)
          
          unique_employees = records.pluck(:employee_id).uniq
          late_records = records.select(&:is_late)
          
          render_success({
            period: { start: params[:start_date], end: params[:end_date] },
            summary: {
              total_records: records.count,
              unique_employees: unique_employees.count,
              total_late: late_records.count,
              total_late_minutes: late_records.sum(&:minutes_late)
            },
            records: records
          })
        end
        
        # GET /api/v1/reports/tardiness
        def tardiness
          unless params[:start_date] && params[:end_date]
            return render_bad_request(['Start date and end date are required'])
          end
          
          company = current_user.company
          employees = company.employees.active.includes(:attendance_records)
          
          report = employees.map do |emp|
            late_records = emp.attendance_records
                             .by_date_range(params[:start_date], params[:end_date])
                             .late_records
            
            total_late_minutes = late_records.sum(:minutes_late)
            
            {
              employee_id: emp.id,
              employee_name: emp.name,
              dni: emp.dni,
              job_position: emp.job_position,
              total_late_days: late_records.count,
              total_late_minutes: total_late_minutes,
              average_late_minutes: late_records.any? ? (total_late_minutes / late_records.count) : 0
            }
          end.select { |r| r[:total_late_days] > 0 }
          
          render_success({
            period: { start: params[:start_date], end: params[:end_date] },
            employees: report,
            total_employees_with_tardiness: report.count
          })
        end
        
        # GET /api/v1/reports/payroll_excel
        def payroll_excel
          unless params[:period_start] && params[:period_end]
            return render_bad_request(['Period start and end are required'])
          end
          
          company = current_user.company
          data = PayrollViewModel.excel_report_data(
            company,
            params[:period_start],
            params[:period_end]
          )
          
          # For now, return JSON data
          # In a full implementation, this would generate actual Excel file
          render_success({
            filename: "nomina_#{params[:period_start]}_#{params[:period_end]}.xlsx",
            data: data
          })
        end
        
        # GET /api/v1/reports/dashboard
        def dashboard
          company = current_user.company
          view_model = DashboardViewModel.new(company)
          
          render_success(view_model.statistics)
        end
      end
    end
  end
end
