# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

gem 'dotenv-rails', '~> 3.1', groups: [:development, :test]

gem 'bcrypt', '~> 3.1'
gem 'bootsnap', '~> 1.18', require: false
gem 'connection_pool', '~> 2.4'
gem 'countries', '~> 6.0'
gem 'faraday', '~> 2.9'
gem 'image_processing', '~> 1.12'
gem 'jbuilder', '~> 2.11'
gem 'json-schema', '~> 5.0'
gem 'marcel', '~> 1.0'
gem 'pg', '~> 1.5'
gem 'phonelib', '~> 0.8.8'
gem 'puma', '~> 6.4'
gem 'rails', '~> 7.1'
gem 'sprockets-rails', '~> 3.4'
gem 'stimulus-rails', '~> 1.3'
gem 'turbo-rails', '~> 2.0'
gem 'tzinfo-data', '~> 1.2024', platforms: %i[mingw mswin x64_mingw jruby]
gem 'view_component', '~> 3.12'

group :development, :test do
  gem 'debug', '~> 1.9', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails', '~> 6.4'
  gem 'factory_bot', '~> 6.4'
  gem 'pry-byebug', '~> 3.10'
  gem 'rubocop-performance', '~> 1.21', require: false
  gem 'rubocop-rails', '~> 2.24', require: false
  gem 'rubocop-rspec', '~> 2.29', require: false
  gem 'rubocop-thread_safety', '~> 0.5.1', require: false
  gem 'rubocop', '~> 1.63', require: false
  gem 'simplecov', '~> 0.22.0', require: false
end

group :development do
  gem 'annotate', '~> 3.2.0'
  gem 'web-console', '~> 4.2'
end

group :test do
  gem 'capybara', '~> 3.40'
  gem 'rspec-rails', '~> 6.1'
  gem 'rspec', '~> 3.4'
  gem 'selenium-webdriver', '~> 4.24'
  gem 'vcr', '~> 6.2'
  gem 'webmock', '~> 3.23'
end
