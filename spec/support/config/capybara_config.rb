# frozen_string_literal: true

Capybara.default_driver = begin
  headful  = StringToBoolean.call(ENV.fetch('HEADFUL', 'false'))
  headless = StringToBoolean.call(ENV.fetch('HEADLESS', 'true'))

  if headful || !headless
    :selenium
  else
    :selenium_headless
  end
end
