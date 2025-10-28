# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  MAX_ATTEMPTS = 25

  queue_as "default"

  # Automatically retry jobs on error
  retry_on StandardError, wait: :polynomially_longer, attempts: MAX_ATTEMPTS
end
