if ENV['HEADFUL'] == 'true'
  Capybara.default_driver = :selenium
else
  Capybara.default_driver = :selenium_headless
end
