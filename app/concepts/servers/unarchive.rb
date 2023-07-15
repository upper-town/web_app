# frozen_string_literal: true

module Servers
  class Unarchive
    def initialize(server)
      @server = server
    end

    def call
      @server.update_column(:archived_at, nil)

      Result.success
    end
  end
end
