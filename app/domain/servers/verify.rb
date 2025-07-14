# frozen_string_literal: true

module Servers
  class Verify
    attr_reader :server

    def initialize(server)
      @server = server
    end

    def call(current_time = Time.current)
      result = VerifyAccounts::Perform.new(server).call(current_time)

      if result.success?
        update_as_verified(current_time)
      else
        update_as_not_verified(result)
      end
    end

    private

    def update_as_verified(current_time)
      server.update!(
        verified_at: current_time,
        metadata: {}
      )
    end

    def update_as_not_verified(result)
      notice = result.errors.full_messages.join("; ")

      server.update!(
        verified_at: nil,
        metadata: { notice: }
      )
    end
  end
end
