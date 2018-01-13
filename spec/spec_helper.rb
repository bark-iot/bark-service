require 'rack/test'
require 'rspec'
require 'pry'
require 'webmock/rspec'

$VERBOSE = nil
ENV['RACK_ENV'] = 'test'
WebMock.disable_net_connect!(allow_localhost: true)

require File.expand_path '../../service.rb', __FILE__

module RSpecMixin
  include Rack::Test::Methods
  def app() Sinatra::Application end
end

RSpec.configure { |c| c.include RSpecMixin }