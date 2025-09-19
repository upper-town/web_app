# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  queue_as "default"

  # Automatically retry jobs on error
  retry_on StandardError, wait: :polynomially_longer, attempts: 25
end
