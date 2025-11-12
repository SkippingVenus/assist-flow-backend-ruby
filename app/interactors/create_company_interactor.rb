# Interactor for creating a company with profile and location
# Handles complex multi-step operations following MVVM pattern
class CreateCompanyInteractor
  attr_reader :profile, :company, :location, :errors

  def initialize(profile)
    @profile = profile
    @errors = []
  end

  # Execute the company creation process
  def call(company_params, location_params = nil)
    ActiveRecord::Base.transaction do
      # Step 1: Create company
      @company = create_company(company_params)
      return failure unless @company

      # Step 2: Link profile to company
      link_profile_to_company
      return failure unless profile.errors.empty?

      # Step 3: Create default location if provided
      if location_params.present?
        @location = create_location(location_params)
        return failure unless @location
      end

      # Step 4: Send notification
      send_success_notification

      success
    rescue StandardError => e
      @errors << "Error al crear empresa: #{e.message}"
      failure
    end
  end

  private

  def create_company(params)
    company = Company.new(params)
    company.created_by = profile.id

    if company.save
      company
    else
      @errors = company.errors.full_messages
      nil
    end
  end

  def link_profile_to_company
    profile.update(company_id: company.id)
    @errors.concat(profile.errors.full_messages) if profile.errors.any?
  end

  def create_location(params)
    location = company.company_locations.build(params)
    location.created_by = profile.id

    if location.save
      location
    else
      @errors = location.errors.full_messages
      nil
    end
  end

  def send_success_notification
    NotificationService.create_notification(
      user: profile,
      title: 'Empresa creada',
      message: "La empresa #{company.name} ha sido creada exitosamente",
      notification_type: 'company_created'
    )
  end

  def success
    {
      success: true,
      company: CompanySerializer.new(company).detailed,
      location: location ? CompanyLocationSerializer.new(location).as_json : nil
    }
  end

  def failure
    {
      success: false,
      errors: errors
    }
  end
end
