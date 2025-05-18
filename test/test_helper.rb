# frozen_string_literal: true

ENV["APP_ENV"] ||= "test"
ENV["RAILS_ENV"] ||= "test"

# TODO: check these imports

require "simplecov"
SimpleCov.start "rails"

require "dotenv"
Dotenv.load(".env.test.local", ".env.local", ".env.test", ".env")

require_relative "../config/environment"

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rails/test_help"

require "minitest/rails"
require "webmock/minitest"

Dir[Rails.root.join("test/support/extensions/*.rb")].each do |file|
  require file
end

Dir[Rails.root.join("test/support/config/*.rb")].each do |file|
  require file
end

Dir[Rails.root.join("test/support/helpers/*.rb")].each do |file|
  require file
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    include ActiveJob::TestHelper

    # Add more helper methods to be used by all tests here...
    include ActiveRecordFactoryTestHelper
    include EnvTestHelper
    include RailsEnvTestHelper
    include CaptchaTestHelper
    include RequestTestHelper
  end
end
