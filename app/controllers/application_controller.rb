# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Auth::AuthenticationControl[User]
  include Auth::AuthorizationControl[User]

  include AddFlashTypes
  include ManageCaptcha

  def auth_root_path
    root_path
  end

  def auth_sign_in_path
    users_sign_in_path
  end

  def auth_sign_out_path
    users_sign_out_path
  end

  def auth_sign_up_path(...)
    users_sign_up_path(...)
  end

  class InvalidQueryParamError < StandardError; end
end
