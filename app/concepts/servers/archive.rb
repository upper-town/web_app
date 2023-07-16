# frozen_string_literal: true

module Servers
  class Archive
    def initialize(server)
      @server = server
    end

    def call
      if @server.archived?
        return Result.failure('Server is already archived')
      end

      @server.update_column(:archived_at, Time.current)

      Result.success
    end
  end
end
