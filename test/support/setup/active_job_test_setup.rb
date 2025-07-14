# frozen_string_literal: true

module ActiveJobTestSetup
  include ActiveJob::TestHelper

  def setup
    super

    clear_enqueued_jobs
    clear_performed_jobs
  end
end
