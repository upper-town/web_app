# frozen_string_literal: true

require_relative '../../../app/concepts/caching'

RSpec.configure do |config|
  config.before do
    Caching.redis.flushdb
  end
end
