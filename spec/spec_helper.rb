# frozen_string_literal: true

require 'simplecov'
SimpleCov.start 'rails'

require 'webmock/rspec'
require 'vcr'
require 'capybara/rspec'
require 'sidekiq/testing'

class StringToBoolean
  TRUE_STR = ['true', 't', '1', 'on', 'enabled'].freeze

  def self.call(value)
    TRUE_STR.include?(value.to_s.downcase.gsub(/[[:space:]]/, ''))
  end
end

Dir[Pathname.getwd.join('spec', 'support', 'config', '**', '*.rb')].each do |file|
  require file
end

Dir[Pathname.getwd.join('spec', 'support', 'helpers', '**', '*.rb')].each do |file|
  require file
end
