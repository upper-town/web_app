# frozen_string_literal: true

module Servers
  class Archive
    def initialize(server)
      @server = server
    end

    def call
      @server.update_column(:archived_at, Time.current)
    end
  end
end
