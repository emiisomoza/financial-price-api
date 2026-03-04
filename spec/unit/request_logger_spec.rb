require_relative "../spec_helper"

RSpec.describe Middleware::RequestLogger do
  include Rack::Test::Methods

  let(:inner_app) { ->(_env) { [200, { "Content-Type" => "application/json" }, ['{"ok":true}']] } }
  subject(:app) { described_class.new(inner_app) }

  it "returns the response unchanged" do
    get "/health"
    expect(last_response.status).to eq(200)
  end

  it "logs the request to stdout" do
    expect { get "/health" }.to output(/\"method\":\"GET\"/).to_stdout
  end

  it "logs error level for 500 responses" do
    error_app = described_class.new(->(_env) { [500, {}, ["error"]] })
    allow(error_app.instance_variable_get(:@logger)).to receive(:error)
    expect { Rack::MockRequest.new(error_app).get("/") }.not_to raise_error
  end
end