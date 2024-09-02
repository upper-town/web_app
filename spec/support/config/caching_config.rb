# frozen_string_literal: true

RSpec.configure do |config|
  config.before do
    Caching.redis.flushdb
  end
end
