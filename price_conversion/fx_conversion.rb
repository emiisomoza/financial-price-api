# Uses: https://open.er-api.com (free, no key needed)
require_relative "base_conversion"

module PriceConversion
  class FxConversion < BaseConversion
    BASE_URL = "https://open.er-api.com/v6/latest"

    def fetch_price(asset:, currency:)
      data = http_get("#{BASE_URL}/#{asset.upcase}")

      raise "FX data unavailable" unless data["result"] == "success"

      rate = data.dig("rates", currency.upcase)
      raise "Currency #{currency} not found" if rate.nil?

      {
        asset: asset.upcase,
        currency: currency.upcase,
        price: rate,
        asset_type: "fx",
        source: "open.er-api.com"
      }
    end
  end
end