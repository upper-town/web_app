# frozen_string_literal: true

module Inside
  class UserAccountsController < BaseController
    def show
      @user_account = current_user_account
    end
  end
end
