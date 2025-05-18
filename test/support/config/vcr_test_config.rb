# frozen_string_literal: true

# VCR.configure do |c|
#   c.cassette_library_dir = 'spec/cassettes'
#   c.hook_into :webmock
#   c.ignore_localhost = true
#   # c.ignore_hosts "chromedriver.storage.googleapis.com" # I'm not sure if this is neeed

#   c.default_cassette_options[:record] = :all if ENV['VCR_RECORD_ALL'] == 'true'

#   c.configure_rspec_metadata!

#   # Example of how to filter sensitive values in VCR records
#   # c.filter_sensitive_data('filtered_SOME_ENV_VAR') { ENV.fetch('SOME_ENV_VAR') }
# end

# # Turned off by default: enable it with the vcr: true tag in tests.
# VCR.turn_off!

# RSpec.configure do |config|
#   config.around(vcr: true) do |example|
#     VCR.turn_on!
#     example.run
#     VCR.turn_off!
#   end
# end
