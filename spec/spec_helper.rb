ENV["RACK_ENV"] = "test"

require "webmock/rspec"
require "rack/test"
require "json"
require_relative "../app"

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.before(:each) do
    WebMock.disable_net_connect!
  end
end

def app
  Sinatra::Application
end