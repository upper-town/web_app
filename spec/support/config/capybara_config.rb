# frozen_string_literal: true

Capybara.default_driver = begin
  headful  = StringValueHelper.to_boolean(ENV.fetch('HEADFUL', 'false'))
  headless = StringValueHelper.to_boolean(ENV.fetch('HEADLESS', 'true'))

  if headful || !headless
    :selenium
  else
    :selenium_headless
  end
end

Capybara.app_host = "http://#{ENV.fetch('APP_HOST')}"
