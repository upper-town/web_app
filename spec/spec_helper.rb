# frozen_string_literal: true

require 'simplecov'
SimpleCov.start 'rails'

require 'webmock/rspec'
require 'vcr'
require 'capybara/rspec'
require 'sidekiq/testing'

require 'support/config/rspec_config'
require 'support/config/vcr_config'
require 'support/config/webmock_config'
require 'support/config/sidekiq_config'
