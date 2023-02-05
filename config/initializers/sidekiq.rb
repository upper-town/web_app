# frozen_string_literal: true

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_SIDEKIQ_URL') }

  config.average_scheduled_poll_interval = 10

  config.on(:startup) do
    schedule_file = 'config/sidekiq_cron.yml'

    if File.exist?(schedule_file)
      Sidekiq::Cron::Job.load_from_hash(YAML.load_file(schedule_file))
    end
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_SIDEKIQ_URL') }
end
