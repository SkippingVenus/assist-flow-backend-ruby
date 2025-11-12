# Serializer for Company model
# Handles JSON representation for API responses following MVVM pattern
class CompanySerializer
  attr_reader :company

  def initialize(company)
    @company = company
  end

  # Basic company information
  def as_json(options = {})
    {
      id: company.id,
      name: company.name,
      expected_start_time: format_time(company.expected_start_time),
      expected_end_time: format_time(company.expected_end_time),
      lunch_start_time: format_time(company.lunch_start_time),
      lunch_end_time: format_time(company.lunch_end_time),
      created_at: company.created_at,
      updated_at: company.updated_at
    }
  end

  # Summary for lists
  def summary
    {
      id: company.id,
      name: company.name
    }
  end

  # Detailed view with locations
  def detailed
    as_json.merge(
      locations: company.company_locations.map do |location|
        CompanyLocationSerializer.new(location).as_json
      end,
      employees_count: company.employees.active.count
    )
  end

  private

  def format_time(time)
    return nil unless time
    time.strftime('%H:%M:%S')
  end
end
