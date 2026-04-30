require_relative "app"

# Rewrite Host header to localhost before Sinatra's middleware stack
# so Rack::Protection::HostAuthorization allows internal Docker calls.
# price-api is a backend-only service, never exposed to the internet.
use(Class.new do
  def initialize(app) = @app = app
  def call(env)
    env["HTTP_HOST"] = "localhost"
    @app.call(env)
  end
end)

run Sinatra::Application
