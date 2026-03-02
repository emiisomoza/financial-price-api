require "faraday"

module PriceConversion
  class BaseConversion
    def fetch_price(asset:, currency:)
      raise NotImplementedError, "#{self.class}#fetch_price must be implemented"
    end

    protected

    def http_get(url, params: {})
      conn = Faraday.new(url: url) do |f|
        f.response :raise_error
        f.adapter Faraday.default_adapter
      end
      response = conn.get("", params)
      JSON.parse(response.body)
    rescue Faraday::Error => e
      raise "External API error: #{e.message}"
    end
  end
end