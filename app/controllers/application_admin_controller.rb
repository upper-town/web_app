# frozen_string_literal: true

class ApplicationAdminController < ActionController::Base
  include Auth::AuthenticationControl[AdminUser]
  include Auth::AuthorizationControl[AdminUser]

  include AddFlashTypes
  include ManageCaptcha

  def auth_root_path
    admin_root_path
  end

  def auth_sign_in_path
    admin_users_sign_in_path
  end

  def auth_sign_out_path
    admin_users_sign_out_path
  end

  def auth_sign_up_path(...)
    admin_users_sign_up_path(...)
  end

  class InvalidQueryParamError < StandardError; end

  layout 'admin'
end
