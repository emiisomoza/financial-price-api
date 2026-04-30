require_relative "../spec_helper"
require_relative "../support/fixtures"

RSpec.describe PriceConversion::StockConversion do
  include Fixtures

  subject(:converter) { described_class.new }

  before do
    allow(ENV).to receive(:fetch).with("ALPHAVANTAGE_API_KEY").and_return("fake_key")

    stub_request(:get, /alphavantage.co/)
      .to_return(status: 200, body: stock_response, headers: { "Content-Type" => "application/json" })

    stub_request(:get, /open.er-api.com/)
      .to_return(status: 200, body: fx_usd_aud_response, headers: { "Content-Type" => "application/json" })
  end

  describe "#fetch_price" do
    it "returns price for AAPL in AUD" do
      result = converter.fetch_price(asset: "AAPL", currency: "AUD")

      expect(result[:asset]).to eq("AAPL")
      expect(result[:currency]).to eq("AUD")
      expect(result[:price]).to eq((180.0 * 1.55).round(4))
      expect(result[:asset_type]).to eq("stock")
    end

    it "returns price in USD without FX conversion" do
      result = converter.fetch_price(asset: "AAPL", currency: "USD")

      expect(result[:price]).to eq(180.0)
    end
  end
end