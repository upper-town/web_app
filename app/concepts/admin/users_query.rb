module Admin
  class UsersQuery
    def initialize
    end

    def call
      User.all
    end
  end
end
