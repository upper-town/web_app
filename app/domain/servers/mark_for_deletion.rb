# frozen_string_literal: true

module Servers
  class MarkForDeletion
    include Callable

    attr_reader :server

    def initialize(server)
      @server = server
    end

    def call
      if server.not_archived?
        Result.failure("Server must be archived and then it can be marked/unmarked for deletion")
      elsif server.marked_for_deletion?
        Result.failure("Server is already marked for deletion")
      else
        server.update!(marked_for_deletion_at: Time.current)

        Result.success
      end
    end
  end
end
