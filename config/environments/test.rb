# frozen_string_literal: true

# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

require "active_support/core_ext/integer/time"

ActiveSupport.on_load(:active_record_postgresqladapter) do
  self.create_unlogged_tables = true
end

BCrypt::Engine.cost = BCrypt::Engine::MIN_COST

Rails.application.routes.default_url_options = {
  host: AppUtil.webapp_host,
  port: AppUtil.webapp_port
}

Rails.application.configure do
  config.hosts << AppUtil.webapp_host
  config.host_authorization = { exclude: ->(request) { request.path == "/up" } }

  config.eager_load = AppUtil.env_var_enabled?("CI")
  config.enable_reloading = false
  config.consider_all_requests_local = true
  config.server_timing = false
  config.assume_ssl = false
  config.force_ssl = false

  config.log_tags = [:request_id]

  if AppUtil.env_var_enabled?("TEST_LOGGER")
    config.log_level = :debug
  else
    config.logger    = Logger.new(nil)
    config.log_level = :fatal
  end

  # cache_store

  config.cache_store = :memory_store

  # public_file_server

  config.public_file_server.enabled = true
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.hour.to_i}" }

  # action_controller

  config.action_controller.raise_on_missing_callback_actions = true
  config.action_controller.default_url_options = {
    host: AppUtil.webapp_host,
    port: AppUtil.webapp_port
  }
  config.action_controller.perform_caching = false
  config.action_controller.allow_forgery_protection = false

  # action_dispatch

  config.action_dispatch.show_exceptions = :rescuable

  # action_view

  config.action_view.annotate_rendered_view_with_filenames = true

  # active_record

  config.active_record.query_log_tags_enabled = false
  config.active_record.verbose_query_logs = false
  config.active_record.dump_schema_after_migration = true
  config.active_record.migration_error = :page_load

  # active_storage

  config.active_storage.service = :test

  # active_job

  # solid_queue

  # mission_control

  # i18n

  config.i18n.raise_on_missing_translations = true

  # active_support

  config.active_support.deprecation = :stderr
  config.active_support.disallowed_deprecation = :raise
  config.active_support.disallowed_deprecation_warnings = []

  # action_mailer

  config.action_mailer.default_url_options = {
    host: AppUtil.webapp_host,
    port: AppUtil.webapp_port
  }
  config.action_mailer.perform_caching = false
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :test
  config.action_mailer.perform_deliveries = true
end
