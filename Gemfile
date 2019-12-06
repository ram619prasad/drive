source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.0'
# For Postgres support
gem 'pg'
# For environment variables
gem 'dotenv-rails'
# Use Puma as the app server
gem 'puma', '~> 3.12'
# For JSON views.
gem 'fast_jsonapi'
# Use Active Model has_secure_password
gem 'bcrypt', '~> 3.1.7'
gem 'jwt'

# For caching and ttl for api_key
gem 'redis'
gem 'browser'

# Use Active Storage variant
gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Mostly for only testing
  # gem 'factory_bot'
  gem 'factory_bot_rails'
  gem 'faker', :git => 'https://github.com/faker-ruby/faker.git', :branch => 'master'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
end

group :development, :production do
  # AWS SDK - 3
  gem 'aws-sdk', '~> 3'
  gem 'aws-sdk-s3', '~> 1'
end

group :test do
  # gem 'database_cleaner-active_record'
  gem 'mocha'
  gem 'shoulda-context'
  gem 'shoulda-matchers'
  gem 'mock_redis'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# For maintaining nested parent-child relationship
gem 'ancestry'

# For pagination
gem 'kaminari'
gem 'api-pagination'
