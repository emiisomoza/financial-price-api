require "sinatra"
require "sinatra/json"
require "dotenv/load"
require_relative "services/price_resolver"
require_relative "middleware/request_logger"
require_relative "services/cache_service"

use Middleware::RequestLogger

set :port, ENV.fetch("PORT", 4567)

get "/v1/price" do
  asset_type = params[:assetType]
  asset      = params[:asset]
  currency   = params[:currency]

  # Validate required params
  missing = []
  missing << "assetType" if asset_type.nil? || asset_type.empty?
  missing << "asset"     if asset.nil? || asset.empty?
  missing << "currency"  if currency.nil? || currency.empty?

  if missing.any?
    halt 400, json(error: "Missing required parameters: #{missing.join(', ')}")
  end

  cache_key = "price:#{asset_type}:#{asset}:#{currency}".downcase

  result = Services::CacheService.fetch(cache_key, asset_type: asset_type) do
    Services::PriceResolver.resolve(
      asset_type: asset_type,
      asset: asset,
      currency: currency
    )
  end

  json result

rescue RuntimeError => e
  halt 422, json(error: e.message)
rescue => e
  halt 500, json(error: "Internal server error", detail: e.message)
end

get "/health" do
  json status: "ok", timestamp: Time.now.iso8601
end