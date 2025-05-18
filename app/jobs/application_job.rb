class ApplicationJob < ActiveJob::Base
  queue_as "default"

  # Automatically retry jobs on error
  retry_on StandardError
end
