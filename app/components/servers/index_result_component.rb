# frozen_string_literal: true

module Servers
  class IndexResultComponent < ApplicationComponent
    def initialize(server:)
      @server = server
    end

    def render?
      @server.present?
    end
  end
end
