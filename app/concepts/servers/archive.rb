# frozen_string_literal: true

module Servers
  class Archive
    attr_reader :server

    def initialize(server)
      @server = server
    end

    def call
      if server.archived?
        return Result.failure('Server is already archived')
      end

      server.update!(archived_at: Time.current)

      Result.success
    end
  end
end
