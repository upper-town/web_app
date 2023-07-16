# frozen_string_literal: true

module Servers
  class Unarchive
    def initialize(server)
      @server = server
    end

    def call
      if @server.marked_for_deletion?
        return Result.failure('Server is marked for deletion. Unmark it first and then you can unarchive it')
      end

      if @server.not_archived?
        return Result.failure('Server is not archived already')
      end

      @server.update_column(:archived_at, nil)

      Result.success
    end
  end
end
