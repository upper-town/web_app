# frozen_string_literal: true

module Admin
  class UsersController < Admin::BaseController
    include Pagy::Backend

    def index
      @pagy, @users = pagy(Admin::UsersQuery.new.call)
    rescue Pagy::OverflowError
      @users = []

      render(status: :not_found)
    end

    def show
    end

    def edit
    end

    def update
    end
  end
end
