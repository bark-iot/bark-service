require 'logger'

configure do
  LOGGER = Logger.new(STDOUT)
end

configure :test do
  LOGGER.level = 'fatal'
end

configure :development do
  require 'pry'
end