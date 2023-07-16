# frozen_string_literal: true

module Servers
  class UnmarkForDeletion
    def initialize(server)
      @server = server
    end

    def call
      if @server.not_archived?
        return Result.failure('Server must be archived and then it can be marked/unmarked for deletion')
      end

      if @server.not_marked_for_deletion?
        return Result.failure('Server is not marked for deletion')
      end

      @server.update_column(:marked_for_deletion_at, nil)

      Result.success
    end
  end
end
