module Admin
  class ServersQuery
    include Callable

    def call
      Server.order(id: :desc)
    end
  end
end
