# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Configure parameters to be partially matched (e.g. passw matches password) and filtered from the log file.
# Use this to limit dissemination of sensitive information.
# See the ActiveSupport::ParameterFilter documentation for supported notations and behaviors.
Rails.application.config.filter_parameters += [
  :_key,
  :_salt,
  :blob,
  :certificate,
  :crypt,
  :cvc,
  :cvv,
  # :email,
  :otp,
  :passw,
  :salt,
  :secret,
  :ssn,
  :token
]
