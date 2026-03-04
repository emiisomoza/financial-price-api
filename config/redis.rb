require "redis"
require "connection_pool"

module Config
  REDIS_POOL = ConnectionPool.new(size: 5, timeout: 5) do
    Redis.new(
      url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0")
    )
  end
end