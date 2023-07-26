# frozen_string_literal: true

module Admin
  class ServersQuery
    def call
      Server.all.order(id: :desc)
    end
  end
end
