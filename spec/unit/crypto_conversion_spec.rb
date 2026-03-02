require_relative "../spec_helper"
require_relative "../support/fixtures"

RSpec.describe PriceConversion::CryptoConversion do
  include Fixtures

  subject(:converter) { described_class.new }

  describe "#fetch_price" do
    before do
      stub_request(:get, /coingecko.com/)
        .to_return(status: 200, body: crypto_response, headers: { "Content-Type" => "application/json" })
    end

    it "returns price for BTC in AUD" do
      result = converter.fetch_price(asset: "BTC", currency: "AUD")

      expect(result[:asset]).to eq("BTC")
      expect(result[:currency]).to eq("AUD")
      expect(result[:price]).to eq(98000.0)
      expect(result[:asset_type]).to eq("crypto")
    end

    it "raises error for unsupported crypto" do
      expect {
        converter.fetch_price(asset: "DOGE99", currency: "AUD")
      }.to raise_error(RuntimeError, /Unsupported crypto/)
    end
  end
end