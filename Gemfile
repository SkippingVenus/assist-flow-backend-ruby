source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '>= 3.2.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 7.1.0'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.5'

# Use Puma as the app server
gem 'puma', '~> 6.0'

# Build JSON APIs with ease
gem 'jbuilder', '~> 2.11'

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 5.0'

# Use Kredis to get higher-level data types in Redis
# gem 'kredis'

# Use Active Model has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Active Storage variants
# gem 'image_processing', '~> 1.2'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS)
gem 'rack-cors'

# JWT authentication
gem 'jwt', '~> 2.7'

# Serializers for JSON responses
gem 'active_model_serializers', '~> 0.10.13'

# Environment variables
gem 'dotenv-rails', '~> 2.8'

# Pagination
gem 'kaminari', '~> 1.2'

# Excel generation
gem 'caxlsx', '~> 3.4'
gem 'caxlsx_rails', '~> 0.6'

# Geolocation calculations
gem 'geocoder', '~> 1.8'

# Rate limiting
gem 'rack-attack', '~> 6.7'

# Background jobs (optional)
# gem 'sidekiq', '~> 7.1'

group :development, :test do
  # Debugging
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  
  # Testing framework
  gem 'rspec-rails', '~> 6.0'
  gem 'factory_bot_rails', '~> 6.2'
  gem 'faker', '~> 3.2'
end

group :development do
  # Code analysis
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  
  # Speed up commands on slow machines / big apps
  # gem 'spring'
end

group :test do
  gem 'shoulda-matchers', '~> 5.3'
  gem 'database_cleaner-active_record', '~> 2.1'
end
