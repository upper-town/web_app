# frozen_string_literal: true

class ApplicationPollingJob < ActiveJob::Base
  queue_as "default"
end
