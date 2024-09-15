# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    def index
      @pagination = Pagination.new(Admin::UsersQuery.new.call, request, per_page: 50)
      @users = @pagination.results

      render(status: @users.empty? ? :not_found : :ok)
    end

    def show
      @user = user_from_params
    end

    private

    def user_from_params
      User.find(params[:id])
    end
  end
end
