# frozen_string_literal: true

module AppUtil
  extend self

  def env_var_enabled?(name, default: nil)
    value = ENV.fetch(normalize_env_var_name(name), default)

    !value.nil? &&
      ["true", "t", "1", "on", "yes", "y", "enable", "enabled"].include?(value.strip.downcase)
  end

  def env_var_disabled?(...)
    !env_var_enabled?(...)
  end

  def normalize_env_var_name(name)
    name.nil? ? nil : name.to_s.strip.upcase
  end

  def running_assets_precompile?
    env_var_enabled?("SECRET_KEY_BASE_DUMMY")
  end

  def show_active_record_log
    ActiveRecord::Base.logger = ActiveSupport::Logger.new($stdout)
  end

  def webapp_host
    ENV.fetch("APP_HOST", "upper.town")
  end

  def webapp_port
    ENV.fetch("APP_PORT", "3000")
  end
end
