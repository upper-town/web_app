# frozen_string_literal: true

require "active_support/core_ext/integer/time"

BCrypt::Engine.cost = BCrypt::Engine::DEFAULT_COST

Rails.application.routes.default_url_options = { host: AppUtil.webapp_host }

Rails.application.configure do
  config.hosts << AppUtil.webapp_host
  config.host_authorization = { exclude: ->(request) { request.path == "/up" } }

  config.eager_load = true
  config.enable_reloading = false
  config.consider_all_requests_local = false
  config.server_timing = false
  config.assume_ssl = true
  config.force_ssl = true

  config.log_level = :info
  config.log_tags  = [:request_id]
  config.silence_healthcheck_path = "/up"

  # cache_store

  config.cache_store = :solid_cache_store

  # public_file_server

  config.public_file_server.enabled = true
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # action_controller

  config.action_controller.raise_on_missing_callback_actions = false
  config.action_controller.perform_caching = true

  # action_dispatch

  config.action_dispatch.show_exceptions = :all

  # action_view

  config.action_view.annotate_rendered_view_with_filenames = false

  # active_record

  config.active_record.query_log_tags_enabled = false
  config.active_record.verbose_query_logs = false
  config.active_record.dump_schema_after_migration = false
  config.active_record.migration_error = false

  # active_storage

  config.active_storage.service = :local

  # active_job

  config.active_job.queue_adapter = :solid_queue
  config.active_job.verbose_enqueue_logs = false

  # solid_queue

  config.solid_queue.connects_to = { database: { writing: :queue } }
  config.solid_queue.shutdown_timeout = 30

  # mission_control

  config.mission_control.jobs.http_basic_auth_enabled = false

  # i18n

  config.i18n.raise_on_missing_translations = false
  config.i18n.fallbacks = true

  # active_support

  config.active_support.report_deprecations = false

  # action_mailer

  config.action_mailer.default_url_options = { host: AppUtil.webapp_host }
  config.action_mailer.perform_caching = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.smtp_settings = {
    # TODO: Configure email service
    address: "localhost",
    port: 1025
  }
end
