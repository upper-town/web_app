require_relative "boot"

require "rails/all"

# Helper methods

def running_assets_precompile?
  [ "true", "1" ].include?(ENV.fetch("SECRET_KEY_BASE_DUMMY", nil))
end

def show_active_record_log
  ActiveRecord::Base.logger = Logger.new($stdout)
end

def web_app_host
  ENV.fetch("APP_HOST", "upper.town")
end

def web_app_port
  ENV.fetch("APP_PORT", "3000")
end

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

    config.time_zone = "UTC"

    config.action_controller.include_all_helpers = true

    unless running_assets_precompile?
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

    config.session_store :cookie_store, key: "app_session"
  end
end
