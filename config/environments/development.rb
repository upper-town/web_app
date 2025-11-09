# frozen_string_literal: true

require "active_support/core_ext/integer/time"

BCrypt::Engine.cost = BCrypt::Engine::DEFAULT_COST

Rails.application.routes.default_url_options = {
  host: AppUtil.webapp_host,
  port: AppUtil.webapp_port
}

Rails.application.configure do
  config.hosts << AppUtil.webapp_host
  config.host_authorization = { exclude: ->(request) { request.path == "/up" } }

  config.eager_load = false
  config.enable_reloading = true
  config.consider_all_requests_local = true
  config.server_timing = true
  config.assume_ssl = false
  config.force_ssl = false

  config.log_level = :debug
  config.log_tags  = [:request_id]

  # cache_store

  config.cache_store = :solid_cache_store

  # public_file_server

  config.public_file_server.enabled = true
  config.public_file_server.headers = { "cache-control" => "public, max-age=5" }

  # action_controller

  config.action_controller.raise_on_missing_callback_actions = true
  config.action_controller.default_url_options = {
    host: AppUtil.webapp_host,
    port: AppUtil.webapp_port
  }
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true
    config.public_file_server.headers = {
      "cache-control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false
  end

  # action_dispatch

  config.action_dispatch.show_exceptions = :all

  # action_view

  config.action_view.annotate_rendered_view_with_filenames = true

  # active_record

  config.active_record.query_log_tags_enabled = true
  config.active_record.verbose_query_logs = true
  config.active_record.dump_schema_after_migration = true
  config.active_record.migration_error = :page_load

  # active_storage

  config.active_storage.service = :local

  # active_job

  config.active_job.queue_adapter = :solid_queue
  config.active_job.verbose_enqueue_logs = true

  # solid_queue

  config.solid_queue.connects_to = { database: { writing: :queue } }
  config.solid_queue.shutdown_timeout = 30
  config.solid_queue.logger = ActiveSupport::Logger.new(Rails.root.join("log/development-jobs.log"))

  # mission_control

  config.mission_control.jobs.http_basic_auth_enabled = false

  # i18n

  config.i18n.raise_on_missing_translations = true

  # active_support

  config.active_support.deprecation = :log
  config.active_support.disallowed_deprecation = :raise
  config.active_support.disallowed_deprecation_warnings = []

  # action_mailer

  config.action_mailer.default_url_options = {
    host: AppUtil.webapp_host,
    port: AppUtil.webapp_port
  }
  config.action_mailer.perform_caching = false
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.smtp_settings = {
    address: "localhost",
    port: 1025
  }
end
