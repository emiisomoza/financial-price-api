# Uses: https://api.coingecko.com (free, no key needed for basic usage)

require_relative "base_conversion"

module PriceConversion
  class CryptoConversion < BaseConversion
    BASE_URL = "https://api.coingecko.com/api/v3"

    COIN_MAP = {
      "BTC"  => "bitcoin",
      "ETH"  => "ethereum",
      "SOL"  => "solana",
      "USDC" => "usd-coin"
    }.freeze

    def fetch_price(asset:, currency:)
      coin_id = COIN_MAP[asset.upcase]
      raise "Unsupported crypto: #{asset}. Supported: #{COIN_MAP.keys.join(', ')}" if coin_id.nil?

      data = http_get("#{BASE_URL}/simple/price", params: {
        ids: coin_id,
        vs_currencies: currency.downcase
      })

      price = data.dig(coin_id, currency.downcase)
      raise "Price not found for #{asset} in #{currency}" if price.nil?

      {
        asset: asset.upcase,
        currency: currency.upcase,
        price: price,
        asset_type: "crypto",
        source: "coingecko.com"
      }
    end
  end
end