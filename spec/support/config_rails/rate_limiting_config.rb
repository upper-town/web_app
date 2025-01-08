# frozen_string_literal: true

require_relative '../../../app/concepts/rate_limiting'

RSpec.configure do |config|
  config.before do
    RateLimiting.redis.flushdb
  end
end
