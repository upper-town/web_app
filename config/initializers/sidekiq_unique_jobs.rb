# frozen_string_literal: true

SidekiqUniqueJobs.configure do |config|
  config.lock_timeout = 3
  config.lock_ttl     = 1.hour.to_i
end
