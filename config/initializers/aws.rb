require 'aws-sdk-s3'  # v2: require 'aws-sdk'

if Rails.env.development?
  S3 = Aws::S3::Client.new
end