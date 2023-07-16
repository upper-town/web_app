# frozen_string_literal: true

module Servers
  class MarkForDeletion
    def initialize(server)
      @server = server
    end

    def call
      if @server.not_archived?
        return Result.failure('Server must be archived and then it can be marked/unmarked for deletion')
      end

      if @server.marked_for_deletion?
        return Result.failure('Server is already marked for deletion')
      end

      @server.update_column(:marked_for_deletion_at, Time.current)

      Result.success
    end
  end
end
