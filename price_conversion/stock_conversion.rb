# Uses: https://www.alphavantage.co (free tier, API key required - sign up free)
# Set ALPHAVANTAGE_API_KEY in .env

require_relative "base_conversion"

module PriceConversion
  class StockConversion < BaseConversion
    BASE_URL = "https://www.alphavantage.co/query"

    def fetch_price(asset:, currency:)
      api_key = ENV.fetch("ALPHAVANTAGE_API_KEY") { raise "ALPHAVANTAGE_API_KEY not set" }

      data = http_get(BASE_URL, params: {
        function: "GLOBAL_QUOTE",
        symbol: asset.upcase,
        apikey: api_key
      })

      price_usd = data.dig("Global Quote", "05. price")&.to_f
      raise "Stock #{asset} not found or market closed" if price_usd.nil? || price_usd == 0

      if currency.upcase == "USD"
        final_price = price_usd
      else
        fx = FxConversion.new
        fx_data = fx.fetch_price(asset: "USD", currency: currency)
        final_price = price_usd * fx_data[:price]
      end

      {
        asset: asset.upcase,
        currency: currency.upcase,
        price: final_price.round(4),
        asset_type: "stock",
        source: "alphavantage.co"
      }
    end
  end
end