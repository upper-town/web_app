# frozen_string_literal: true

module CapybaraTestSetup
  extend ActiveSupport::Concern

  class_methods do
    def capybara_default_driver
      headful  = AppUtil.env_var_enabled?("HEADFUL") || AppUtil.env_var_enabled?("DEV_TOOLS")
      headless = AppUtil.env_var_enabled?("HEADLESS", default: "true")

      if headful || !headless
        :selenium
      else
        :selenium_headless
      end
    end
  end

  included do
    driven_by(capybara_default_driver) do |capabilities|
      if AppUtil.env_var_enabled?("DEV_TOOLS")
        capabilities.add_argument("--auto-open-devtools-for-tabs")
        capabilities.add_preference("devtools", "preferences" => { "currentDockState" => '"bottom"' })
      end
    end
  end

  def setup
    super

    Capybara.app_host = "http://#{AppUtil.webapp_host}:#{AppUtil.webapp_port}"
    Capybara.server_host = AppUtil.webapp_host
    Capybara.server_port = AppUtil.webapp_port
  end
end
