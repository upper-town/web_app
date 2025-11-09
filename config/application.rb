require_relative "boot"

require "rails/all"

require_relative "../lib/app_util"

require "dotenv" if Rails.env.local?

if Rails.env.development?
  Dotenv.load(".env.local", ".env")
elsif Rails.env.test?
  Dotenv.load(".env.test.local", ".env.test", ".env.local", ".env")
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Webapp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

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

    config.time_zone = "UTC"

    config.action_controller.include_all_helpers = true

    config.active_model.i18n_customize_full_message = true

    unless AppUtil.running_assets_precompile?
      config.active_record.encryption.primary_key =
        ENV.fetch("ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY").split(",")
      config.active_record.encryption.deterministic_key =
        ENV.fetch("ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY").split(",")
      config.active_record.encryption.key_derivation_salt =
        ENV.fetch("ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT")
    end

    ActiveSupport.on_load(:active_record_postgresqladapter) do
      self.datetime_type = :timestamptz
    end

    config.session_store :cookie_store, key: "rails_session"
  end
end
