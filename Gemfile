# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'dotenv-rails', '~> 3.1', groups: [:development, :test]

gem 'rails', '~> 8.0', '>= 8.0.1'

gem 'bootsnap', '~> 1.18', '>= 1.18.4', require: false
gem 'puma', '~> 6.6'

gem 'kamal', '~> 2.4', require: false
gem 'thruster', '~> 0.1.10', require: false

gem 'bcrypt', '~> 3.1', '>= 3.1.20'

gem 'pg', '~> 1.5', '>= 1.5.9'

gem 'solid_cable', '~> 3.0', '>= 3.0.7'
gem 'solid_cache', '~> 1.0', '>= 1.0.6'
gem 'solid_queue', '~> 1.1', '>= 1.1.3'

gem 'mission_control-jobs', '~> 1.0', '>= 1.0.1'

gem 'propshaft', '~> 1.1'

gem 'importmap-rails', '~> 2.1'
gem 'stimulus-rails', '~> 1.3', '>= 1.3.4'
gem 'turbo-rails', '~> 2.0', '>= 2.0.11'
gem 'view_component', '~> 3.8'

gem 'image_processing', '~> 1.13'

gem 'jbuilder', '~> 2.13'
gem 'json-schema', '~> 5.1', '>= 5.1.1'

gem 'countries', '~> 7.1'
gem 'faraday', '~> 2.12', '>= 2.12.2'
gem 'phonelib', '~> 0.10.3'

gem 'tzinfo-data', platforms: %i[windows mingw mswin x64_mingw jruby]

group :development, :test do
  gem 'debug', '~> 1.10', platforms: %i[mri mingw x64_mingw], require: 'debug/prelude'
  gem 'brakeman', '~> 7.0', require: false

  gem 'factory_bot_rails', '~> 6.4', '>= 6.4.4'
  gem 'factory_bot', '~> 6.5', '>= 6.5.1'

  gem 'rubocop-capybara', '~> 2.21', require: false
  gem 'rubocop-factory_bot', '~> 2.26', '>= 2.26.1'
  gem 'rubocop-performance', '~> 1.23', '>= 1.23.1', require: false
  gem 'rubocop-rails', '~> 2.29', '>= 2.29.1', require: false
  gem 'rubocop-rspec_rails', '~> 2.30', require: false
  gem 'rubocop-rspec', '~> 3.4', require: false
  gem 'rubocop-thread_safety', '~> 0.6.0', require: false
  gem 'rubocop', '~> 1.71', '>= 1.71.1', require: false

  gem 'simplecov', '~> 0.22.0', require: false
end

group :development do
  gem 'foreman', '~> 0.88.1'
  gem 'mailcatcher', '~> 0.10.0'
  gem 'web-console', '~> 4.2', '>= 4.2.1'
end

group :test do
  gem 'capybara', '~> 3.40'
  gem 'selenium-webdriver', '~> 4.28'

  gem 'rspec-rails', '~> 7.1'
  gem 'rspec', '~> 3.13'

  gem 'vcr', '~> 6.3', '>= 6.3.1'
  gem 'webmock', '~> 3.24'
end
