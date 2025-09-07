# frozen_string_literal: true

module AppUtil
  extend self

  def env_var_enabled?(name)
    value = ENV.fetch(normalize_env_var_name(name), nil)

    !value.nil? &&
      ["true", "t", "1", "on", "yes", "y", "enable", "enabled"].include?(value.strip.downcase)
  end

  def env_var_disabled?(name)
    !env_var_enabled?(name)
  end

  def normalize_env_var_name(name)
    name.nil? ? nil : name.to_s.strip.upcase
  end

  def running_assets_precompile?
    env_var_enabled?("SECRET_KEY_BASE_DUMMY")
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
end
