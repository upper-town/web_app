# frozen_string_literal: true

module Servers
  class VerifySchedulerJob < ApplicationJob
    queue_as "low"
    limits_concurrency key: ->(*) { "0" }

    def perform
      Server.select(:id).not_archived.each do |server|
        VerifyJob.perform_later(server)
      end
    end
  end
end
