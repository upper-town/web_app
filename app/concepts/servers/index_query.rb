# frozen_string_literal: true

module Servers
  class IndexQuery
    def call
      Server.all
    end
  end
end
