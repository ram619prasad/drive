require 'mock_redis'

if Rails.env.test?
  REDIS_CLIENT = MockRedis.new
end

unless Rails.env.test?
  REDIS_CLIENT = Redis.new(host: ENV['REDIS_HOST'], port: ENV['REDIS_PORT'], db: 1)
end
