module Servers
  class Unarchive
    attr_reader :server

    def initialize(server)
      @server = server
    end

    def call
      if server.marked_for_deletion?
        Result.failure("Server is marked for deletion. Unmark it first and then you can unarchive it")
      elsif server.not_archived?
        Result.failure("Server is not archived already")
      else
        server.update!(archived_at: nil)

        Result.success
      end
    end
  end
end
