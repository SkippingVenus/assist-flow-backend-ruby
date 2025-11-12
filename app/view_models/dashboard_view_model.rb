# ViewModel for Dashboard presentation logic
# Aggregates data from multiple sources for dashboard views

class DashboardViewModel
  attr_reader :company
  
  def initialize(company)
    @company = company
  end
  
  # Main dashboard statistics
  def statistics
    {
      total_employees: total_employees_count,
      today_attendance: today_attendance_count,
      today_late: today_late_count,
      pending_vacations: pending_vacations_count,
      this_month_stats: this_month_statistics
    }
  end
  
  # Today's overview
  def today_overview
    today = Date.today
    
    {
      date: today,
      attendance: AttendanceViewModel.company_daily_report(company, today),
      notifications: recent_notifications,
      pending_approvals: pending_approvals
    }
  end
  
  # Monthly overview
  def monthly_overview(month = Date.today.month, year = Date.today.year)
    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month
    
    {
      period: { month: month, year: year },
      total_working_days: calculate_working_days(start_date, end_date),
      attendance_summary: monthly_attendance_summary(start_date, end_date),
      tardiness_summary: monthly_tardiness_summary(start_date, end_date),
      vacation_summary: monthly_vacation_summary(start_date, end_date)
    }
  end
  
  private
  
  def total_employees_count
    company.employees.active.count
  end
  
  def today_attendance_count
    today = Date.today
    company.employees.active.joins(:attendance_records)
           .where(attendance_records: { record_date: today, attendance_type: 'entrance' })
           .distinct
           .count
  end
  
  def today_late_count
    today = Date.today
    AttendanceRecord.joins(:employee)
                    .where(employees: { company_id: company.id })
                    .where(record_date: today, is_late: true)
                    .count
  end
  
  def pending_vacations_count
    company.vacation_requests.pending.count
  end
  
  def this_month_statistics
    start_date = Date.today.beginning_of_month
    end_date = Date.today.end_of_month
    
    {
      total_attendance_records: AttendanceRecord.joins(:employee)
                                                .where(employees: { company_id: company.id })
                                                .by_date_range(start_date, end_date)
                                                .count,
      total_late_records: AttendanceRecord.joins(:employee)
                                          .where(employees: { company_id: company.id })
                                          .by_date_range(start_date, end_date)
                                          .late_records
                                          .count,
      approved_vacations: company.vacation_requests.approved
                                 .where('start_date >= ? AND end_date <= ?', start_date, end_date)
                                 .count
    }
  end
  
  def recent_notifications
    company.notifications.recent.limit(10).map do |n|
      {
        id: n.id,
        type: n.type,
        title: n.title,
        message: n.message,
        is_read: n.is_read,
        created_at: n.created_at
      }
    end
  end
  
  def pending_approvals
    {
      vacation_requests: company.vacation_requests.pending.count,
      total_pending: company.vacation_requests.pending.count
    }
  end
  
  def calculate_working_days(start_date, end_date)
    (start_date..end_date).count { |date| date.on_weekday? }
  end
  
  def monthly_attendance_summary(start_date, end_date)
    records = AttendanceRecord.joins(:employee)
                              .where(employees: { company_id: company.id })
                              .by_date_range(start_date, end_date)
    
    {
      total_records: records.count,
      unique_employees: records.pluck(:employee_id).uniq.count,
      average_daily_attendance: records.count / ((end_date - start_date).to_i + 1)
    }
  end
  
  def monthly_tardiness_summary(start_date, end_date)
    late_records = AttendanceRecord.joins(:employee)
                                   .where(employees: { company_id: company.id })
                                   .by_date_range(start_date, end_date)
                                   .late_records
    
    {
      total_late_incidents: late_records.count,
      total_late_minutes: late_records.sum(:minutes_late),
      average_late_minutes: late_records.any? ? (late_records.sum(:minutes_late) / late_records.count) : 0
    }
  end
  
  def monthly_vacation_summary(start_date, end_date)
    {
      total_requests: company.vacation_requests
                            .where('created_at >= ? AND created_at <= ?', start_date, end_date)
                            .count,
      approved: company.vacation_requests.approved
                      .where('start_date >= ? AND end_date <= ?', start_date, end_date)
                      .count,
      pending: company.vacation_requests.pending
                     .where('created_at >= ?', start_date)
                     .count
    }
  end
end
