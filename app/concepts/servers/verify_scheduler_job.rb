# frozen_string_literal: true

module Servers
  class VerifySchedulerJob
    include Sidekiq::Job

    sidekiq_options(lock: :while_executing)

    def perform
      Server.ids.each do |server_id|
        VerifyJob.perform_async(server_id)
      end
    end
  end
end
