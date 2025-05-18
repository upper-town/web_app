module Admin
  class UsersQuery
    include Callable

    def call
      User.order(id: :desc)
    end
  end
end
