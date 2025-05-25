# frozen_string_literal: true

module ActiveJobTestSetup
  include ActiveJob::TestHelper

  def setup
    clear_enqueued_jobs
    clear_performed_jobs

    super
  end
end
