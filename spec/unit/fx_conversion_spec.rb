require_relative "../spec_helper"
require_relative "../support/fixtures"

RSpec.describe PriceConversion::FxConversion do
  include Fixtures

  subject(:converter) { described_class.new }

  describe "#fetch_price" do
    before do
      stub_request(:get, /open.er-api.com/)
        .to_return(status: 200, body: fx_response, headers: { "Content-Type" => "application/json" })
    end

    it "returns price for valid asset and currency" do
      result = converter.fetch_price(asset: "USD", currency: "AUD")

      expect(result[:asset]).to eq("USD")
      expect(result[:currency]).to eq("AUD")
      expect(result[:price]).to eq(1.55)
      expect(result[:asset_type]).to eq("fx")
    end

    it "raises error for unknown currency" do
      stub_request(:get, /open.er-api.com/)
        .to_return(status: 200, body: { "result" => "success", "rates" => {} }.to_json)

      expect {
        converter.fetch_price(asset: "USD", currency: "XYZ")
      }.to raise_error(RuntimeError, /not found/)
    end

    it "raises error when external API fails" do
      stub_request(:get, /open.er-api.com/).to_return(status: 500)

      expect {
        converter.fetch_price(asset: "USD", currency: "AUD")
      }.to raise_error(RuntimeError, /External API error/)
    end
  end
end