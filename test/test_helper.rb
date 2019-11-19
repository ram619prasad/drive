ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'mocha/minitest'
# require 'aws-sdk-s3'

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: 4)

  # FactoryBot support
  include FactoryBot::Syntax::Methods
  FactoryBot::SyntaxRunner.class_eval do
    include ActionDispatch::TestProcess
  end

  # Add more helper methods to be used by all tests here...
  Shoulda::Matchers.configure do |config|
    config.integrate do |with|
      with.test_framework :minitest
      with.library :rails
    end
  end

  def assert_raises_with_message(exception, msg, &block)
    block.call
  rescue exception => e
    assert_match msg, e.message
  else
    raise "Expected to raise #{exception} w/ message #{msg}, none raised"
  end

  def sign_in(user)
    payload = { id: user.id }
    JsonWebToken.encode(payload)
  end

  def current_user(token)
    payload = JsonWebToken.decode(token) || {}
    User.find(payload[:id])
  end

  def json_response
    JSON.parse(@response.body)
  end

  def unauthorized_route_assertions
    assert_response :unauthorized
    assert json_response.key?('message')
    assert_equal 'You are not authorized to perform this action.', json_response['message']
  end
  
end
