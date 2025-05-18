require 'spec_helper'

ENV['APP_ENV'] ||= 'test'
ENV['RAILS_ENV'] ||= 'test'

require_relative '../config/environment'

# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

require 'capybara/rails'

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

Rails.root.glob('spec/support/config_rails/**/*.rb').each do |file|
  require file
end

Rails.root.glob('spec/support/helpers_rails/**/*.rb').each do |file|
  require file
end
