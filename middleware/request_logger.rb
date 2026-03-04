require "logger"
require "json"
require "time"

module Middleware
  class RequestLogger
    def initialize(app)
      @app = app
      @logger = Logger.new($stdout)
      @logger.formatter = proc { |_severity, _datetime, _progname, msg| "#{msg}\n" }
    end

    def call(env)
      started_at = Time.now
      status, headers, body = @app.call(env)
      duration_ms = ((Time.now - started_at) * 1000).round(2)

      log_request(env, status, duration_ms)

      [status, headers, body]
    end

    private

    def log_request(env, status, duration_ms)
      log = {
        timestamp: Time.now.utc.iso8601,
        method: env["REQUEST_METHOD"],
        path: env["PATH_INFO"],
        query: env["QUERY_STRING"],
        status: status,
        duration_ms: duration_ms,
        ip: env["HTTP_X_FORWARDED_FOR"] || env["REMOTE_ADDR"],
        user_agent: env["HTTP_USER_AGENT"]
      }

      level = status >= 500 ? :error : status >= 400 ? :warn : :info
      @logger.send(level, log.to_json)
    end
  end
end