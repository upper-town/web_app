# frozen_string_literal: true

module Admin
  class BaseController < ApplicationAdminUserController
    before_action :authenticate_admin_user!
  end
end
