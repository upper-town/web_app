# frozen_string_literal: true

module Admin
  class UsersQuery
    def call
      User.all.order(id: :desc)
    end
  end
end
