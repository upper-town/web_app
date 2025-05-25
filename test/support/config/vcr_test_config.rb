# frozen_string_literal: true

VCR.configure do |c|
  c.cassette_library_dir = "test/cassettes"
  c.hook_into :webmock
  c.ignore_localhost = true
  # c.ignore_hosts "chromedriver.storage.googleapis.com" # I'm not sure if this is neeed

  c.default_cassette_options[:record] = :all if ["true", "1"].include?(ENV.fetch("VCR_RECORD_ALL", "false"))

  # Example of how to filter sensitive values in VCR records
  # c.filter_sensitive_data("filtered_SOME_ENV_VAR") { ENV.fetch("SOME_ENV_VAR") }
end

# Turned off by default. Use it with VCR.use_cassette method
VCR.turn_off!
