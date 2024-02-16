# frozen_string_literal: true

module Caching
  def self.redis
    Thread.current[:caching_redis] ||= build_redis
  end

  def self.build_redis
    ConnectionPool::Wrapper.new do
      Redis.new(url: ENV.fetch('REDIS_CACHE_URL'))
    end
  end
end
