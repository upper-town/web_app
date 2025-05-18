require 'simplecov'
SimpleCov.start 'rails'

require 'dotenv'
Dotenv.load('.env.test.local', '.env.local', '.env.test', '.env')

require 'webmock/rspec'
require 'vcr'
require 'capybara/rspec'

Dir[Pathname.getwd.join('spec', 'support', 'config', '**', '*.rb')].each do |file|
  require file
end

Dir[Pathname.getwd.join('spec', 'support', 'helpers', '**', '*.rb')].each do |file|
  require file
end
