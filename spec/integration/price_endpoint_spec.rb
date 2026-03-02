require_relative "../spec_helper"
require_relative "../support/fixtures"

RSpec.describe "GET /v1/price", type: :integration do
  include Fixtures

  describe "successful requests" do
    before do
      stub_request(:get, "https://open.er-api.com/v6/latest/USD")
        .to_return(
          status: 200,
          body: fx_response,
          headers: { "Content-Type" => "application/json" }
        )
    end

    it "returns 200 with valid params" do
      get "/v1/price?assetType=fx&asset=USD&currency=AUD"

      expect(last_response.status).to eq(200)
      body = JSON.parse(last_response.body)
      expect(body["asset"]).to eq("USD")
      expect(body["currency"]).to eq("AUD")
      expect(body["price"]).to eq(1.55)
    end
  end

  describe "validation errors" do
    it "returns 400 when assetType is missing" do
      get "/v1/price?asset=USD&currency=AUD"

      expect(last_response.status).to eq(400)
      body = JSON.parse(last_response.body)
      expect(body["error"]).to include("assetType")
    end

    it "returns 400 when asset is missing" do
      get "/v1/price?assetType=fx&currency=AUD"

      expect(last_response.status).to eq(400)
    end

    it "returns 400 when currency is missing" do
      get "/v1/price?assetType=fx&asset=USD"

      expect(last_response.status).to eq(400)
    end

    it "returns 422 for unsupported assetType" do
      get "/v1/price?assetType=nft&asset=BAYC&currency=AUD"

      expect(last_response.status).to eq(422)
      body = JSON.parse(last_response.body)
      expect(body["error"]).to include("Unsupported asset_type")
    end
  end

  describe "health check" do
    it "returns 200" do
      get "/health"

      expect(last_response.status).to eq(200)
      body = JSON.parse(last_response.body)
      expect(body["status"]).to eq("ok")
    end
  end
end