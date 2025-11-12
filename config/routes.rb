Rails.application.routes.draw do
  # Health check
  get '/health', to: 'health#index'
  
  namespace :api do
    namespace :v1 do
      # Authentication routes
      post 'auth/register', to: 'auth#register'
      post 'auth/admin/login', to: 'auth#admin_login'
      post 'auth/employee/login', to: 'auth#employee_login'
      get 'auth/me', to: 'auth#me'
      get 'auth/companies', to: 'auth#companies'
      
      # Companies
      resources :companies, only: [:show, :update] do
        member do
          get 'locations', to: 'companies#locations'
          post 'locations', to: 'companies#create_location'
        end
        
        resources :locations, only: [:update, :destroy], controller: 'company_locations'
      end
      
      # Employees
      resources :employees do
        member do
          post 'reset_credentials'
        end
      end
      
      # Attendance Records
      resources :attendance_records, only: [:create, :index] do
        collection do
          get 'today'
          get 'employee/:employee_id', to: 'attendance_records#by_employee'
          get 'company/:company_id/daily', to: 'attendance_records#company_daily'
          get 'stats/:employee_id', to: 'attendance_records#stats'
        end
      end
      
      # Vacation Requests
      resources :vacation_requests, only: [:index, :create] do
        member do
          patch 'approve'
          patch 'reject'
        end
      end
      
      # Notifications
      resources :notifications, only: [:index] do
        collection do
          get 'unread_count'
          patch 'mark_all_read'
        end
        
        member do
          patch 'mark_read'
        end
      end
      
      # Payroll Calculations
      resources :payroll_calculations, only: [:index, :show] do
        collection do
          post 'calculate'
        end
      end
      
      # Reports
      namespace :reports do
        get 'attendance'
        get 'tardiness'
        get 'payroll_excel'
        get 'dashboard'
      end
    end
  end
  
  # Root route
  root to: proc { [200, {}, ['AsistControl API - Ruby on Rails']] }
end
