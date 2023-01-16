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
      @user = user_from_params
    end

    private

    def user_from_params
      User.find(params['id'])
    end
  end
end
