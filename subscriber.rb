def configure(*envs)
  yield self if envs.empty? || envs.include?(ENV['RACK_ENV'].to_sym)
end

require './config/logging.rb'
require './config/database.rb'
require './config/concepts.rb'
require 'redis'
require 'json'

REDIS = Redis.new(url: ENV['REDIS_URL'], timeout: 0)
LOGGER.info "Started listening events on #{ENV['REDIS_URL']}"

#TODO: listen to triggers and actions delete actions
begin
  REDIS.subscribe('houses') do |on|
    on.message do |channel, msg|
      puts "##{channel} - #{msg}"
      data = JSON.parse(msg)
      case data['type']
        when 'deleted'
          House::Delete.(house_id: data['house']['id'])
        else
          LOGGER.warn "Unsupported type #{data['type']}"
      end
    end
  end
rescue StandardError => e
  LOGGER.error e.message
  LOGGER.error e.backtrace
end