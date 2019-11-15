ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'mocha/minitest'
require 'aws-sdk-s3'

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: 4)

  # FactoryBot support
  include FactoryBot::Syntax::Methods

  # Add more helper methods to be used by all tests here...
  Shoulda::Matchers.configure do |config|
    config.integrate do |with|
      with.test_framework :minitest
      with.library :rails
    end
  end
end
