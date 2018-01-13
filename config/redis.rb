require 'redis'

configure do
  REDIS = Redis.new(url: ENV['REDIS_URL'])
end