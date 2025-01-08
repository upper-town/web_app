# frozen_string_literal: true

def str_to_boolean(str)
  ['true', 't', '1', 'on', 'enabled'].include?(str.downcase)
end

def capybara_select_default_driver
  headful  = str_to_boolean(ENV.fetch('HEADFUL', 'false'))
  headless = str_to_boolean(ENV.fetch('HEADLESS', 'true'))

  if headful || !headless
    :selenium
  else
    :selenium_headless
  end
end

Capybara.default_driver = capybara_select_default_driver
Capybara.javascript_driver = Capybara.default_driver

Capybara.app_host = "http://#{ENV.fetch('APP_HOST')}"

RSpec.configure do |config|
  config.before(type: :system) do
    driven_by(Capybara.default_driver)
  end

  config.before(type: :system, js: true) do
    driven_by(Capybara.javascript_driver)
  end
end
