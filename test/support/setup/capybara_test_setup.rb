# frozen_string_literal: true

module CapybaraTestSetup
  extend ActiveSupport::Concern

  class_methods do
    def capybara_default_driver
      headful  = AppUtil.env_var_enabled?("HEADFUL")
      headless = AppUtil.env_var_enabled?("HEADLESS")

      if headful || !headless
        :selenium
      else
        :selenium_headless
      end
    end
  end

  included do
    driven_by(capybara_default_driver)
  end

  def setup
    super

    Capybara.app_host = "http://#{AppUtil.web_app_host}:#{AppUtil.web_app_port}"
    Capybara.server_host = AppUtil.web_app_host
    Capybara.server_port = AppUtil.web_app_port
  end
end
