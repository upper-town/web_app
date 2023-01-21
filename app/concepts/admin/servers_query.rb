# frozen_string_literal: true

module Admin
  class ServersQuery
    def call
      Server.all
    end
  end
end
