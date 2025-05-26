# frozen_string_literal: true

module CapybaraTestSetup
  def setup
    Capybara.default_driver = capybara_select_default_driver
    Capybara.javascript_driver = Capybara.default_driver

    Capybara.app_host = "http://#{ENV.fetch('APP_HOST')}"

    super
  end

  private

  def capybara_select_default_driver
    headful  = ENV.fetch("HEADFUL", "false") == "true"
    headless = ENV.fetch("HEADLESS", "true") == "true"

    if headful || !headless
      :selenium
    else
      :selenium_headless
    end
  end
end
