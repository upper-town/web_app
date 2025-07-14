# frozen_string_literal: true

VCR.configure do |c|
  c.cassette_library_dir = "test/cassettes"
  c.hook_into :webmock
  c.ignore_localhost = true

  if ENV.fetch("VCR_RECORD_ALL", "false") == "true"
    c.default_cassette_options[:record] = :all
  end

  # Example of how to filter sensitive values in VCR records
  # c.filter_sensitive_data("filtered_SOME_ENV_VAR") { ENV.fetch("SOME_ENV_VAR") }
end

# Turned off by default. Use it with VCR.use_cassette method
VCR.turn_off!
