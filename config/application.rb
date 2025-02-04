# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module WebApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.time_zone = 'UTC'

    config.generators.system_tests = nil
    config.action_controller.include_all_helpers = true

    config.active_record.encryption.primary_key =
      ENV.fetch('ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY').split(',')
    config.active_record.encryption.deterministic_key =
      ENV.fetch('ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY').split(',')
    config.active_record.encryption.key_derivation_salt =
      ENV.fetch('ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT')

    ActiveSupport.on_load(:active_record_postgresqladapter) do
      self.datetime_type = :timestamptz
    end

    config.session_store :cookie_store, key: 'app_session'
  end
end
