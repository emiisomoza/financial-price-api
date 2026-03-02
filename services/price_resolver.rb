require_relative "../price_conversion//fx_conversion"
require_relative "../price_conversion/crypto_conversion"
require_relative "../price_conversion/stock_conversion"

module Services
  class PriceResolver
    STRATEGY_MAP = {
      "fx"     => PriceConversion::FxConversion,
      "crypto" => PriceConversion::CryptoConversion,
      "stock"  => PriceConversion::StockConversion
    }.freeze

    def self.resolve(asset_type:, asset:, currency:)
      conversion_class = STRATEGY_MAP[asset_type.downcase]
      raise "Unsupported asset_type: '#{asset_type}'. Valid: #{STRATEGY_MAP.keys.join(', ')}" if conversion_class.nil?

      conversion_class.new.fetch_price(asset: asset, currency: currency)
    end
  end
end