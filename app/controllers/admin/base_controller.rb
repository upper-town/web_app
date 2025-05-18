module Admin
  class BaseController < ApplicationAdminController
    before_action :authenticate_admin_user!
  end
end
