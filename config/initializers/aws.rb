require 'aws-sdk-s3'  # v2: require 'aws-sdk'
require "mocha/minitest"

unless Rails.env.test?
  S3 = Aws::S3::Client.new
end

if Rails.env.test?
  S3 = Aws::S3::Client.new(stub_responses: true)
end