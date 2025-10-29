# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  ATTEMPTS = 25

  queue_as "default"

  # Automatically retry jobs on error
  retry_on StandardError, wait: :polynomially_longer, attempts: ATTEMPTS
end
