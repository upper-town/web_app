# frozen_string_literal: true

module CapybaraTestSetup
  extend ActiveSupport::Concern

  class_methods do
    def capybara_default_driver
      headful  = ENV.fetch("HEADFUL", "false") == "true"
      headless = ENV.fetch("HEADLESS", "true") == "true"

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

    Capybara.app_host = "http://#{web_app_host}:#{web_app_port}"
    Capybara.server_host = web_app_host
    Capybara.server_port = web_app_port
  end
end
