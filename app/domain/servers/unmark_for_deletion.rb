module Servers
  class UnmarkForDeletion
    include Callable

    attr_reader :server

    def initialize(server)
      @server = server
    end

    def call
      if server.not_archived?
        Result.failure("Server must be archived and then it can be marked/unmarked for deletion")
      elsif server.not_marked_for_deletion?
        Result.failure("Server is already not marked for deletion")
      else
        server.update!(marked_for_deletion_at: nil)

        Result.success
      end
    end
  end
end
