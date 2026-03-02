# Uses: https://finnhub.io (free tier, API key required - sign up free)
# Set FINNHUB_API_KEY in .env

require_relative "base_conversion"

module PriceConversion
  class StockConversion < BaseConversion
    BASE_URL = "https://finnhub.io/api/v1"

    def fetch_price(asset:, currency:)
      api_key = ENV.fetch("FINNHUB_API_KEY") { raise "FINNHUB_API_KEY not set" }

      # Get price in USD first
      data = http_get("#{BASE_URL}/quote", params: {
        symbol: asset.upcase,
        token: api_key
      })

      price_usd = data["c"] # current price
      raise "Stock #{asset} not found or market closed" if price_usd.nil? || price_usd == 0

      # Convert to target currency if not USD
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
        source: "finnhub.io"
      }
    end
  end
end