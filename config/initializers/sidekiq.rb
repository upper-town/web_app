# frozen_string_literal: true

require 'sidekiq'
require 'sidekiq-unique-jobs'

Sidekiq.configure_server do |config|
  config.redis = {
    url: "redis://#{ENV.fetch('REDIS_HOST')}:#{ENV.fetch('REDIS_PORT')}/#{ENV.fetch('REDIS_SIDEKIQ_DB')}"
  }

  config.average_scheduled_poll_interval = 10

  config.on(:startup) do
    schedule_file = 'config/sidekiq_cron.yml'

    if File.exist?(schedule_file)
      Sidekiq::Cron::Job.load_from_hash(YAML.load_file(schedule_file))
    end
  end

  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end

  config.server_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Server
  end

  SidekiqUniqueJobs::Server.configure(config)
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: "redis://#{ENV.fetch('REDIS_HOST')}:#{ENV.fetch('REDIS_PORT')}/#{ENV.fetch('REDIS_SIDEKIQ_DB')}"
  }

  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end
end
