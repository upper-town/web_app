module Inside
  class AccountsController < BaseController
    def show
      @account = current_account
    end
  end
end
