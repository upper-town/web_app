# frozen_string_literal: true

module Servers
  class Verify
    def initialize(server)
      @server = server
    end

    def call(current_time = Time.current)
      ActiveRecord::Base.transaction do
        result = VerifyLinkedUserAccounts.new(@server).call(current_time)

        if result.success?
          update_as_verified(current_time)
        else
          update_as_pending(current_time, result)
        end
      end
    end

    private

    def update_as_verified(current_time)
      @server.update!(
        verify_status: Server::VERIFIED,
        verify_notice: '',
        verify_updated_at: current_time,
      )
    end

    def update_as_pending(current_time, result)
      notice = result.errors.full_messages.join('; ')

      @server.update!(
        verify_status: Server::PENDING,
        verify_notice: notice,
        verify_updated_at: current_time,
      )
    end
  end
end
