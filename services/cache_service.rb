require_relative "../config/redis"

module Services
  class CacheService
    def self.ttl_by_asset_type
      {
        "fx"     => ENV.fetch("CACHE_TTL_FX", 300).to_i,
        "stock"  => ENV.fetch("CACHE_TTL_STOCK", 60).to_i,
        "crypto" => ENV.fetch("CACHE_TTL_CRYPTO", 15).to_i
      }.freeze
    end

    def self.default_ttl
      ENV.fetch("CACHE_TTL_DEFAULT", 60).to_i
    end

    def self.fetch(key, asset_type: nil, ttl: nil, &block)
      ttl ||= ttl_by_asset_type.fetch(asset_type.to_s, default_ttl)

      Config::REDIS_POOL.with do |redis|
        cached = redis.get(key)
        return JSON.parse(cached, symbolize_names: true) if cached

        result = block.call
        redis.setex(key, ttl, result.to_json)
        result
      end
    rescue Redis::BaseError => e
      warn "Cache error: #{e.message} — falling through to API"
      block.call
    end
  end
end