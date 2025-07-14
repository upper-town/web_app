# frozen_string_literal: true

ENV["APP_ENV"] ||= "test"
ENV["RAILS_ENV"] ||= "test"

require "simplecov"
SimpleCov.start "rails"

require_relative "../config/environment"

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rails/test_help"

require "minitest/rails"
require "webmock/minitest"

Rails.root.glob("test/support/extensions/*.rb").each do |file|
  require file
end

Rails.root.glob("test/support/config/*.rb").each do |file|
  require file
end

Rails.root.glob("test/support/setup/*.rb").each do |file|
  require file
end

Rails.root.glob("test/support/helpers/*.rb").each do |file|
  require file
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    include ActiveJobTestSetup
    include CacheTestSetup
    include CurrentTestSetup
    include MailerTestSetup

    include ActiveRecordFactoryTestHelper
    include EnvTestHelper
    include RailsEnvTestHelper
    include RequestTestHelper

    include Rails.application.routes.url_helpers
  end
end
