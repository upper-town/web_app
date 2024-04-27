# frozen_string_literal: true

module Caching
  def self.redis
    Thread.current[:caching_redis] ||= build_redis
  end

  def self.redis_url
    "redis://#{ENV.fetch('REDIS_HOST')}:#{ENV.fetch('REDIS_PORT')}/#{ENV.fetch('REDIS_CACHE_DB')}"
  end

  def self.build_redis
    ConnectionPool::Wrapper.new do
      Redis.new(url: redis_url)
    end
  end
end
