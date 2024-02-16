# frozen_string_literal: true

module RateLimiting
  def self.redis
    Thread.current[:rate_limiting_redis] ||= build_redis
  end

  def self.build_redis
    ConnectionPool::Wrapper.new do
      Redis.new(url: ENV.fetch('REDIS_RATE_LIMITER_URL'))
    end
  end
end
