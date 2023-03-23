# frozen_string_literal: true

module Servers
  class VerifyJob
    include Sidekiq::Job

    sidekiq_options(lock: :while_executing)

    def perform(server_id)
      server = Server.find(server_id)

      Verify.new(server).call
    end
  end
end
