# frozen_string_literal: true

module Servers
  class UnmarkForDeletion
    def initialize(server)
      @server = server
    end

    def call
      @server.update_column(:marked_for_deletion_at, nil)
    end
  end
end
