# frozen_string_literal: true

module RateLimiting
  module Client
    def self.build_redis_client
      ConnectionPool::Wrapper.new do
        Redis.new(url: ENV.fetch('REDIS_RATE_LIMITER_URL'))
      end
    end
  end
end
