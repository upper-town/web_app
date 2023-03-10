# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.0'

gem 'dotenv-rails', '~> 2.8', groups: [:development, :test]

# Use main development branch of Rails
gem 'rails', github: 'rails/rails', branch: 'main'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 5.0'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem 'tailwindcss-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 5.0'

gem 'connection_pool', '~> 2.3'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Sass to process CSS
# gem "sassc-rails"

gem 'devise', '~> 4.9'

gem 'view_component', '~> 2.62'

gem 'faraday', '~> 2.4'

gem 'sidekiq', '~> 7.0'
gem 'sidekiq-cron', '~> 1.9'
gem 'sidekiq-unique-jobs', '~> 8.0'

gem 'phonelib', '~> 0.7.0'

gem 'base58_id', '~> 1.1.0'

gem 'pagy', '~> 6.0.0'

gem 'countries', '~> 5.3.0'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[ mri mingw x64_mingw ]

  gem 'factory_bot', '~> 6.2'
  gem 'factory_bot_rails', '~> 6.2'
  gem 'rspec', '~> 3.11'
  gem 'rspec-rails', '~> 5.1'
  gem 'shoulda-matchers', '~> 5.1'
  gem 'simplecov', '~> 0.21', require: false

  gem 'rubocop', '~> 1.32', require: false
  gem 'rubocop-performance', '~> 1.14', require: false
  gem 'rubocop-rails', '~> 2.15', require: false
  gem 'rubocop-rspec', '~> 2.12', require: false
  gem 'rubocop-thread_safety', '~> 0.4.4', require: false

  gem 'pry-byebug', '~> 3.9'

  gem 'faker', '~> 3.1'
end

group :development do
  gem 'annotate', '~> 3.2.0'

  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  gem 'capybara', '~> 3.37'
  gem 'selenium-webdriver', '~> 4.3'
  gem 'vcr', '~> 6.1'
  gem 'webmock', '~> 3.14'
end
