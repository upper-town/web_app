ENV['APP_ENV'] ||= 'test'

require 'simplecov'
SimpleCov.start 'rails'

require 'webmock/rspec'
require 'vcr'
require 'capybara/rspec'

require 'support/rspec_config'

require 'support/vcr_config'
require 'support/factory_bot_config'
require 'support/webmock_config'
