# frozen_string_literal: true

class ApplicationPollingJob < ActiveJob::Base
  queue_as "polling"
end
