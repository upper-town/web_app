# frozen_string_literal: true

Capybara.default_driver =
  if ENV['HEADFUL'] == 'true'
    :selenium
  else
    :selenium_headless
  end
